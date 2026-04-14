-- Auth profile extensions, trust score v1, and trust-aware leaderboard ranking.

alter table public.profiles
  add column if not exists avatar_url text,
  add column if not exists trust_score numeric(5,2) not null default 0;

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

  -- Completeness over the last 30 reports.
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

  -- Conservative quality signal until reviewer linkage is finalized.
  select coalesce(
    count(*) filter (where status = 'open')::numeric / nullif(count(*)::numeric, 0),
    0
  )
  into open_quality_flag_ratio
  from public.data_quality_flags;

  computed :=
    base_score +
    (30 * completeness_ratio) +
    (25 * greatest(least(avg_species_confidence, 1), 0)) +
    (15 * (1 - greatest(least(duplicate_grid_ratio, 1), 0))) +
    (10 * (1 - greatest(least(open_quality_flag_ratio, 1), 0)));

  update public.profiles
  set trust_score = greatest(0, least(100, round(computed, 2))),
      updated_at = now()
  where id = target_user_id;
end;
$$;

create or replace function public.tree_reports_trust_score_after_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.recompute_profile_trust_score(new.user_id);
  return new;
end;
$$;

drop trigger if exists tree_reports_trust_score_after_insert on public.tree_reports;
create trigger tree_reports_trust_score_after_insert
  after insert on public.tree_reports
  for each row
  execute procedure public.tree_reports_trust_score_after_insert();

drop view if exists public.leaderboard_national;
drop view if exists public.leaderboard_city;

create or replace view public.leaderboard_national as
select
  p.id as user_id,
  p.display_name,
  p.avatar_url,
  p.city_label,
  p.city_slug,
  p.total_points,
  p.trust_score,
  ((p.total_points * 0.8)::numeric + (p.trust_score * 2.0))::numeric(10,2) as leaderboard_score
from public.profiles p
where p.total_points > 0
order by leaderboard_score desc, p.total_points desc, p.trust_score desc, p.updated_at asc;

create or replace view public.leaderboard_city as
select
  p.id as user_id,
  p.display_name,
  p.avatar_url,
  p.city_label,
  p.city_slug,
  p.total_points,
  p.trust_score,
  ((p.total_points * 0.8)::numeric + (p.trust_score * 2.0))::numeric(10,2) as leaderboard_score
from public.profiles p
where p.total_points > 0 and p.city_slug is not null
order by p.city_slug asc, leaderboard_score desc, p.total_points desc, p.trust_score desc, p.updated_at asc;

grant select on public.leaderboard_national to anon, authenticated;
grant select on public.leaderboard_city to anon, authenticated;
