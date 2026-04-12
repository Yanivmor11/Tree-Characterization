-- Gamification, profiles, species, pest hotspots, quality flags, scoring triggers.
-- Requires Supabase Auth with anonymous sign-in enabled for full client flow.

-- ---------------------------------------------------------------------------
-- profiles
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  city_label text,
  city_slug text,
  total_points int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists profiles_city_slug_idx on public.profiles (city_slug);
create index if not exists profiles_total_points_idx on public.profiles (total_points desc);

alter table public.profiles enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
drop policy if exists "profiles_leaderboard_read" on public.profiles;
drop policy if exists "profiles_select_public" on public.profiles;
-- Public read for leaderboard fields (no sensitive columns on this table).
create policy "profiles_select_public" on public.profiles
  for select using (true);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own" on public.profiles
  for insert with check (auth.uid() = id);

-- ---------------------------------------------------------------------------
-- tree_reports extensions
-- ---------------------------------------------------------------------------
alter table public.tree_reports add column if not exists user_id uuid references auth.users (id);
alter table public.tree_reports add column if not exists species text;
alter table public.tree_reports add column if not exists species_scientific text;
alter table public.tree_reports add column if not exists species_confidence double precision;
alter table public.tree_reports add column if not exists ai_suggestion_json jsonb;
alter table public.tree_reports add column if not exists insights_text text;

create index if not exists tree_reports_user_id_idx on public.tree_reports (user_id);
create index if not exists tree_reports_species_idx on public.tree_reports (lower(species));
create index if not exists tree_reports_lat_lon_idx on public.tree_reports (latitude, longitude);

-- Replace wide-open demo policies with auth-scoped insert + public read
drop policy if exists "tree_reports_insert_all" on public.tree_reports;
drop policy if exists "tree_reports_select_all" on public.tree_reports;

create policy "tree_reports_select_all" on public.tree_reports
  for select using (true);

create policy "tree_reports_insert_authenticated" on public.tree_reports
  for insert to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "tree_reports_update_own" on public.tree_reports;
create policy "tree_reports_update_own" on public.tree_reports
  for update to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- report_scores
-- ---------------------------------------------------------------------------
create table if not exists public.report_scores (
  report_id uuid primary key references public.tree_reports (id) on delete cascade,
  points_breakdown jsonb not null default '{}',
  total int not null default 0,
  created_at timestamptz not null default now()
);

alter table public.report_scores enable row level security;

drop policy if exists "report_scores_read_all" on public.report_scores;
create policy "report_scores_read_all" on public.report_scores
  for select using (true);

-- ---------------------------------------------------------------------------
-- user_badges
-- ---------------------------------------------------------------------------
create table if not exists public.user_badges (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  badge_code text not null,
  earned_at timestamptz not null default now(),
  unique (user_id, badge_code)
);

create index if not exists user_badges_user_idx on public.user_badges (user_id);

alter table public.user_badges enable row level security;

drop policy if exists "user_badges_select_own" on public.user_badges;
create policy "user_badges_select_own" on public.user_badges
  for select using (auth.uid() = user_id);

drop policy if exists "user_badges_read_all" on public.user_badges;
create policy "user_badges_read_all" on public.user_badges
  for select using (true);

-- ---------------------------------------------------------------------------
-- pest_hotspots
-- ---------------------------------------------------------------------------
create table if not exists public.pest_hotspots (
  id uuid primary key default gen_random_uuid(),
  pest_code text not null,
  label text not null,
  latitude double precision not null,
  longitude double precision not null,
  radius_m double precision not null default 500,
  severity int not null default 1,
  source text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists pest_hotspots_active_idx on public.pest_hotspots (active);

alter table public.pest_hotspots enable row level security;

drop policy if exists "pest_hotspots_read" on public.pest_hotspots;
create policy "pest_hotspots_read" on public.pest_hotspots
  for select using (active = true);

-- ---------------------------------------------------------------------------
-- data_quality_flags (researcher review)
-- ---------------------------------------------------------------------------
create table if not exists public.data_quality_flags (
  id uuid primary key default gen_random_uuid(),
  cluster_key text not null,
  reason text not null,
  payload jsonb not null default '{}',
  status text not null default 'open' check (status in ('open', 'reviewed', 'dismissed')),
  created_at timestamptz not null default now()
);

create index if not exists data_quality_flags_status_idx on public.data_quality_flags (status);

alter table public.data_quality_flags enable row level security;

drop policy if exists "data_quality_flags_read_all" on public.data_quality_flags;
create policy "data_quality_flags_read_all" on public.data_quality_flags
  for select using (true);

-- ---------------------------------------------------------------------------
-- New user -> profile row
-- ---------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'display_name', 'Guardian')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Gamification: scoring + badges after report insert
-- ---------------------------------------------------------------------------
create or replace function public.tree_report_gamification_after_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  base_pts int := 10;
  flower_pts int := 0;
  leaf_pts int := 0;
  land_pts int := 0;
  total_pts int;
  profile_city text;
  prior_species_count int;
  neighborhood_count int;
begin
  if new.user_id is null then
    return new;
  end if;

  if cardinality(new.flower_image_urls) > 0 then
    flower_pts := 15;
  end if;

  if cardinality(new.leaves_image_urls) >= 2 then
    leaf_pts := 10;
  end if;

  if new.land_type_auto = true then
    land_pts := 5;
  end if;

  total_pts := base_pts + flower_pts + leaf_pts + land_pts;

  insert into public.report_scores (report_id, points_breakdown, total)
  values (
    new.id,
    jsonb_build_object(
      'base', base_pts,
      'flower_fruit', flower_pts,
      'leaf_detail', leaf_pts,
      'land_use', land_pts
    ),
    total_pts
  )
  on conflict (report_id) do nothing;

  update public.profiles
  set total_points = total_points + total_pts,
      updated_at = now()
  where id = new.user_id;

  select city_slug into profile_city
  from public.profiles
  where id = new.user_id;

  -- First Bloom Hunter: first flowering-stage report of this species in this city (by profile city_slug)
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
      insert into public.user_badges (user_id, badge_code)
      values (new.user_id, 'first_bloom_hunter')
      on conflict (user_id, badge_code) do nothing;
    end if;
  end if;

  -- Neighborhood Watch: 5+ reports by same user in same ~100m grid (3 decimal degrees)
  select count(*) into neighborhood_count
  from public.tree_reports tr
  where tr.user_id = new.user_id
    and round(tr.latitude::numeric, 3) = round(new.latitude::numeric, 3)
    and round(tr.longitude::numeric, 3) = round(new.longitude::numeric, 3);

  if neighborhood_count >= 5 then
    insert into public.user_badges (user_id, badge_code)
    values (new.user_id, 'neighborhood_watch')
    on conflict (user_id, badge_code) do nothing;
  end if;

  return new;
end;
$$;

drop trigger if exists tree_reports_gamification_after_insert on public.tree_reports;
create trigger tree_reports_gamification_after_insert
  after insert on public.tree_reports
  for each row execute procedure public.tree_report_gamification_after_insert();

-- ---------------------------------------------------------------------------
-- Leaderboard views
-- ---------------------------------------------------------------------------
create or replace view public.leaderboard_national as
select
  p.id as user_id,
  p.display_name,
  p.city_label,
  p.city_slug,
  p.total_points
from public.profiles p
where p.total_points > 0
order by p.total_points desc;

create or replace view public.leaderboard_city as
select
  p.id as user_id,
  p.display_name,
  p.city_label,
  p.city_slug,
  p.total_points
from public.profiles p
where p.total_points > 0 and p.city_slug is not null
order by p.city_slug asc, p.total_points desc;

grant select on public.leaderboard_national to anon, authenticated;
grant select on public.leaderboard_city to anon, authenticated;

-- Species frequency for “rare tree” map hints (client may cache).
create or replace view public.species_report_counts as
select
  lower(trim(species)) as species_key,
  count(*)::int as report_count
from public.tree_reports
where species is not null and trim(species) <> ''
group by lower(trim(species));

grant select on public.species_report_counts to anon, authenticated;

-- ---------------------------------------------------------------------------
-- Demo pest hotspot (Tel Aviv area) — replace with curated data
-- ---------------------------------------------------------------------------
insert into public.pest_hotspots (pest_code, label, latitude, longitude, radius_m, severity, source)
select 'red_palm_weevil', 'Red palm weevil activity (demo hotspot)', 32.0853, 34.7818, 500, 3, 'seed'
where not exists (
  select 1 from public.pest_hotspots ph
  where ph.pest_code = 'red_palm_weevil' and ph.source = 'seed'
  limit 1
);
