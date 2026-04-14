-- Gamification hardening: idempotent point awards and extensible badge catalog.

create table if not exists public.badge_definitions (
  code text primary key,
  display_name text not null,
  description text not null,
  category text not null default 'milestone',
  active boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.badge_definitions enable row level security;

drop policy if exists "badge_definitions_read_all" on public.badge_definitions;
create policy "badge_definitions_read_all" on public.badge_definitions
  for select using (active = true);

insert into public.badge_definitions (code, display_name, description, category)
values
  ('first_blossom_reporter', 'First Blossom Reporter', 'Submitted the first phenological report.', 'phenology'),
  ('private_land_pioneer', 'Private Land Pioneer', 'Submitted a first report that maps private land tree context.', 'land-use'),
  ('first_bloom_hunter', 'First Bloom Hunter', 'First flowering-stage report for a species in the reporter city.', 'phenology'),
  ('neighborhood_watch', 'Neighborhood Watch', 'Contributed 5 reports in the same local grid.', 'community')
on conflict (code) do update
set display_name = excluded.display_name,
    description = excluded.description,
    category = excluded.category,
    active = true;

create or replace function public.grant_user_badge(target_user_id uuid, badge_code text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if target_user_id is null or badge_code is null then
    return;
  end if;

  if exists (
    select 1
    from public.badge_definitions bd
    where bd.code = badge_code and bd.active = true
  ) then
    insert into public.user_badges (user_id, badge_code)
    values (target_user_id, badge_code)
    on conflict (user_id, badge_code) do nothing;
  end if;
end;
$$;

create or replace function public.tree_report_gamification_after_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  full_report_points constant int := 25;
  total_pts int := full_report_points;
  previous_total int := 0;
  points_delta int := 0;
  profile_city text;
  prior_species_count int;
  neighborhood_count int;
  phenology_count int;
  private_land_count int;
begin
  if new.user_id is null then
    return new;
  end if;

  select coalesce(rs.total, 0) into previous_total
  from public.report_scores rs
  where rs.report_id = new.id;

  insert into public.report_scores (report_id, points_breakdown, total)
  values (
    new.id,
    jsonb_build_object('full_report', total_pts),
    total_pts
  )
  on conflict (report_id) do update
    set points_breakdown = excluded.points_breakdown,
        total = excluded.total;

  points_delta := total_pts - previous_total;

  if points_delta <> 0 then
    update public.profiles
    set total_points = greatest(0, total_points + points_delta),
        updated_at = now()
    where id = new.user_id;
  end if;

  select city_slug into profile_city
  from public.profiles
  where id = new.user_id;

  select count(*) into phenology_count
  from public.tree_reports tr
  where tr.user_id = new.user_id
    and tr.phenological_stage in ('bud', 'open', 'fruit');

  if phenology_count = 1 and new.phenological_stage in ('bud', 'open', 'fruit') then
    perform public.grant_user_badge(new.user_id, 'first_blossom_reporter');
  end if;

  select count(*) into private_land_count
  from public.tree_reports tr
  where tr.user_id = new.user_id
    and tr.land_type = 'private';

  if private_land_count = 1 and new.land_type = 'private' then
    perform public.grant_user_badge(new.user_id, 'private_land_pioneer');
  end if;

  if new.species is not null
     and profile_city is not null
     and new.phenological_stage in ('bud', 'open') then
    select count(*) into prior_species_count
    from public.tree_reports tr
    join public.profiles p on p.id = tr.user_id
    where tr.id <> new.id
      and p.city_slug is not distinct from profile_city
      and lower(trim(tr.species)) = lower(trim(new.species))
      and tr.phenological_stage in ('bud', 'open');

    if prior_species_count = 0 then
      perform public.grant_user_badge(new.user_id, 'first_bloom_hunter');
    end if;
  end if;

  select count(*) into neighborhood_count
  from public.tree_reports tr
  where tr.user_id = new.user_id
    and round(tr.latitude::numeric, 3) = round(new.latitude::numeric, 3)
    and round(tr.longitude::numeric, 3) = round(new.longitude::numeric, 3);

  if neighborhood_count >= 5 then
    perform public.grant_user_badge(new.user_id, 'neighborhood_watch');
  end if;

  return new;
end;
$$;

grant select on public.badge_definitions to anon, authenticated;
