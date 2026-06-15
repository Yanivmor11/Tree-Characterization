-- ============================================================================
-- Social feed — report votes, net_votes cache, GIS source metadata
-- ============================================================================
-- Adds community upvote/downvote with automatic net_votes cache on tree_reports,
-- trust-score community component, and land_type_source for GIS provenance.
--
-- Depends on: 20260417100000_auth_profiles_trust_leaderboard.sql
-- ============================================================================

-- GIS provenance metadata (local_zone | osm | default | manual)
alter table public.tree_reports
  add column if not exists land_type_source text
    check (land_type_source in ('local_zone', 'osm', 'default', 'manual'));

-- Cached community vote tally for feed rendering
alter table public.tree_reports
  add column if not exists net_votes int not null default 0;

create index if not exists tree_reports_net_votes_idx
  on public.tree_reports (net_votes desc, created_at desc);

-- ---------------------------------------------------------------------------
-- report_votes
-- ---------------------------------------------------------------------------
create table if not exists public.report_votes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  report_id uuid not null references public.tree_reports (id) on delete cascade,
  vote_type text not null check (vote_type in ('up', 'down')),
  created_at timestamptz not null default now(),
  unique (user_id, report_id)
);

create index if not exists report_votes_report_id_idx
  on public.report_votes (report_id);

create index if not exists report_votes_user_id_idx
  on public.report_votes (user_id);

alter table public.report_votes enable row level security;

drop policy if exists "report_votes_select_all" on public.report_votes;
create policy "report_votes_select_all" on public.report_votes
  for select using (true);

drop policy if exists "report_votes_insert_own" on public.report_votes;
create policy "report_votes_insert_own" on public.report_votes
  for insert to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "report_votes_update_own" on public.report_votes;
create policy "report_votes_update_own" on public.report_votes
  for update to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "report_votes_delete_own" on public.report_votes;
create policy "report_votes_delete_own" on public.report_votes
  for delete to authenticated
  using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- Vote change handler — net_votes cache + trust score + downvote audit
-- ---------------------------------------------------------------------------
create or replace function public.handle_report_vote_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  affected_report_id uuid;
  report_owner_id uuid;
  new_net_votes int;
  existing_flag_id uuid;
begin
  if TG_OP = 'DELETE' then
    affected_report_id := OLD.report_id;
  else
    affected_report_id := NEW.report_id;
  end if;

  select coalesce(
    sum(
      case
        when vote_type = 'up' then 1
        when vote_type = 'down' then -1
        else 0
      end
    ),
    0
  )::int
  into new_net_votes
  from public.report_votes
  where report_id = affected_report_id;

  update public.tree_reports
  set net_votes = new_net_votes
  where id = affected_report_id
  returning user_id into report_owner_id;

  if report_owner_id is not null then
    perform public.recompute_profile_trust_score(report_owner_id);
  end if;

  if new_net_votes <= -5 then
    select id into existing_flag_id
    from public.data_quality_flags
    where cluster_key = 'report:' || affected_report_id::text
      and status = 'open'
    limit 1;

    if existing_flag_id is null then
      insert into public.data_quality_flags (cluster_key, reason, payload, status)
      values (
        'report:' || affected_report_id::text,
        'community_downvote_audit',
        jsonb_build_object(
          'report_id', affected_report_id,
          'net_votes', new_net_votes
        ),
        'open'
      );
    end if;
  end if;

  if TG_OP = 'DELETE' then
    return OLD;
  end if;
  return NEW;
end;
$$;

drop trigger if exists report_votes_change on public.report_votes;
create trigger report_votes_change
  after insert or update or delete on public.report_votes
  for each row
  execute procedure public.handle_report_vote_change();

-- ---------------------------------------------------------------------------
-- Trust score — add bounded community-vote component
-- ---------------------------------------------------------------------------
create or replace function public.recompute_profile_trust_score(target_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  report_count int := 0;
  completeness_ratio numeric := 0;
  avg_species_confidence numeric := 0;
  duplicate_grid_ratio numeric := 0;
  open_quality_flag_ratio numeric := 0;
  community_vote_total int := 0;
  community_vote_bonus numeric := 0;
  base_score numeric := 20;
  computed numeric := 0;
begin
  if target_user_id is null then
    return;
  end if;

  select count(*) into report_count
  from public.tree_reports tr
  where tr.user_id = target_user_id;

  if report_count = 0 then
    update public.profiles
    set trust_score = 0,
        updated_at = now()
    where id = target_user_id;
    return;
  end if;

  with recent as (
    select *
    from public.tree_reports tr
    where tr.user_id = target_user_id
    order by tr.created_at desc
    limit 30
  ),
  scores as (
    select avg(
      (
        (case when cardinality(whole_tree_image_urls) > 0 then 1 else 0 end) +
        (case when cardinality(flower_image_urls) > 0 then 1 else 0 end) +
        (case when cardinality(leaves_image_urls) > 0 then 1 else 0 end) +
        (case when land_type is not null then 1 else 0 end) +
        (case when health_score is not null then 1 else 0 end) +
        (case when canopy_density is not null then 1 else 0 end) +
        (case when damage_extent is not null then 1 else 0 end) +
        (case when species is not null and trim(species) <> '' then 1 else 0 end)
      ) / 8.0
    ) as score
    from recent
  )
  select coalesce(score, 0) into completeness_ratio
  from scores;

  select coalesce(avg(species_confidence), 0) into avg_species_confidence
  from (
    select tr.species_confidence
    from public.tree_reports tr
    where tr.user_id = target_user_id and tr.species_confidence is not null
    order by tr.created_at desc
    limit 30
  ) recent_conf;

  with grid_counts as (
    select round(tr.latitude::numeric, 3) as lat3,
           round(tr.longitude::numeric, 3) as lon3,
           count(*) as c
    from public.tree_reports tr
    where tr.user_id = target_user_id
    group by 1, 2
  )
  select coalesce(
    greatest(sum(case when c > 1 then c - 1 else 0 end), 0)::numeric /
    nullif(sum(c)::numeric, 0),
    0
  )
  into duplicate_grid_ratio
  from grid_counts;

  select coalesce(
    count(*) filter (where status = 'open')::numeric / nullif(count(*)::numeric, 0),
    0
  )
  into open_quality_flag_ratio
  from public.data_quality_flags;

  select coalesce(sum(tr.net_votes), 0)::int
  into community_vote_total
  from public.tree_reports tr
  where tr.user_id = target_user_id;

  community_vote_bonus := greatest(-15, least(15, community_vote_total * 0.5));

  computed :=
    base_score +
    (30 * completeness_ratio) +
    (25 * greatest(least(avg_species_confidence, 1), 0)) +
    (15 * (1 - greatest(least(duplicate_grid_ratio, 1), 0))) +
    (10 * (1 - greatest(least(open_quality_flag_ratio, 1), 0))) +
    community_vote_bonus;

  update public.profiles
  set trust_score = greatest(0, least(100, round(computed, 2))),
      updated_at = now()
  where id = target_user_id;
end;
$$;

notify pgrst, 'reload schema';
