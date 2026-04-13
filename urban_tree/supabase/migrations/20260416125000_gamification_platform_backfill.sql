-- Comprehensive backfill for environments where gamification migration history
-- was marked applied before all objects were materialized.

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

drop policy if exists "profiles_select_public" on public.profiles;
create policy "profiles_select_public" on public.profiles
  for select using (true);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own" on public.profiles
  for insert with check (auth.uid() = id);

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

notify pgrst, 'reload schema';
