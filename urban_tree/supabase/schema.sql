-- UrbanTree: optional one-off run in Supabase SQL Editor. For CLI deploys, the same DDL lives in
-- supabase/migrations/20260401100000_initial_schema.sql (keep in sync when editing).

create extension if not exists "pgcrypto";

-- Land use for map overlays + auto-classification (axis-aligned bounding boxes).
-- Layering: when a point falls in multiple boxes, the row with the highest layer_priority wins;
-- if tied, the smaller-area box wins (more specific parcel).
create table if not exists public.land_zones (
  id uuid primary key default gen_random_uuid(),
  land_type text not null check (land_type in ('public', 'private', 'kkl', 'abandoned')),
  label text,
  min_lat double precision not null,
  max_lat double precision not null,
  max_lon double precision not null,
  min_lon double precision not null,
  layer_priority int not null default 0,
  created_at timestamptz not null default now(),
  constraint land_zones_lat_order check (min_lat <= max_lat),
  constraint land_zones_lon_order check (min_lon <= max_lon)
);

create index if not exists land_zones_type_idx on public.land_zones (land_type);

create table if not exists public.tree_reports (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  latitude double precision not null,
  longitude double precision not null,
  accuracy_meters double precision,
  land_type text not null check (land_type in ('public', 'private', 'kkl', 'abandoned')),
  land_type_auto boolean not null default false,
  health_score int not null check (health_score between 1 and 5),
  canopy_density text not null check (canopy_density in ('sparse', 'moderate', 'dense')),
  structural_issues text[] not null default '{}',
  whole_tree_image_urls text[] not null default '{}',
  flower_image_urls text[] not null default '{}',
  phenological_stage text,
  flower_abundance text,
  leaves_image_urls text[] not null default '{}',
  leaf_condition text not null check (leaf_condition in ('healthy', 'stressed')),
  damage_extent text not null check (
    damage_extent in ('minimal', 'low', 'moderate', 'high')
  ),
  constraint flower_stage_check check (
    phenological_stage is null
    or phenological_stage in ('bud', 'open', 'fruit')
  ),
  constraint flower_abundance_check check (
    flower_abundance is null
    or flower_abundance in ('low', 'medium', 'high')
  )
);

alter table public.land_zones enable row level security;
alter table public.tree_reports enable row level security;

-- Demo policies: replace with auth-scoped rules before production.
drop policy if exists "land_zones_read_all" on public.land_zones;
create policy "land_zones_read_all" on public.land_zones for select using (true);

drop policy if exists "tree_reports_insert_all" on public.tree_reports;
create policy "tree_reports_insert_all" on public.tree_reports for insert with check (true);

drop policy if exists "tree_reports_select_all" on public.tree_reports;
create policy "tree_reports_select_all" on public.tree_reports for select using (true);

-- Storage bucket for report photos (create bucket in Dashboard if this fails on older projects).
insert into storage.buckets (id, name, public)
values ('tree-report-media', 'tree-report-media', true)
on conflict (id) do nothing;

drop policy if exists "tree_media_public_read" on storage.objects;
create policy "tree_media_public_read" on storage.objects
for select using (bucket_id = 'tree-report-media');

drop policy if exists "tree_media_public_upload" on storage.objects;
create policy "tree_media_public_upload" on storage.objects
for insert with check (bucket_id = 'tree-report-media');

drop policy if exists "tree_media_public_update" on storage.objects;
create policy "tree_media_public_update" on storage.objects
for update using (bucket_id = 'tree-report-media');

-- Demo zones (Tel Aviv-ish bbox — replace with GIS-derived boxes). Fixed UUIDs so re-runs are idempotent.
insert into public.land_zones (id, land_type, label, min_lat, max_lat, min_lon, max_lon, layer_priority)
values
  ('a0000001-0000-4000-8000-000000000001'::uuid, 'public', 'Example public corridor', 32.06, 32.11, 34.76, 34.80, 0),
  ('a0000002-0000-4000-8000-000000000002'::uuid, 'private', 'Example private enclave', 32.07, 32.09, 34.77, 34.79, 10),
  ('a0000003-0000-4000-8000-000000000003'::uuid, 'kkl', 'Example KKL zone', 32.08, 32.10, 34.775, 34.795, 5),
  ('a0000004-0000-4000-8000-000000000004'::uuid, 'abandoned', 'Example abandoned parcel', 32.065, 32.075, 34.765, 34.775, 2)
on conflict (id) do nothing;

-- Extended schema (profiles, gamification, pest hotspots, quality flags, views): see
-- migrations/20260413100000_gamification_platform.sql (requires Supabase Auth, anonymous sign-in).
