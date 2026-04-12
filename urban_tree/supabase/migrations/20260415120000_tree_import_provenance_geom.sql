-- Municipal import support: physiological verification flag, provenance, and WGS84 geometry
-- derived from existing latitude/longitude (same CRS as the Flutter client).

create extension if not exists postgis;

alter table public.tree_reports
  add column if not exists needs_physiological_update boolean not null default false;

alter table public.tree_reports
  add column if not exists import_source text;

alter table public.tree_reports
  add column if not exists external_id text;

create index if not exists tree_reports_import_source_idx
  on public.tree_reports (import_source)
  where import_source is not null;

-- Single PostGIS point per report (lon, lat) in WGS84 — populated automatically from lat/lon.
do $geom$
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'tree_reports'
      and column_name = 'geom'
  ) then
    alter table public.tree_reports
      add column geom geometry(Point, 4326)
      generated always as (
        ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
      ) stored;
  end if;
end
$geom$;

create index if not exists tree_reports_geom_gix
  on public.tree_reports using gist (geom);
