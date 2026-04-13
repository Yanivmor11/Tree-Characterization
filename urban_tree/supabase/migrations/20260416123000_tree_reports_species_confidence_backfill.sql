-- Defensive backfill for projects where species columns were marked applied but not materialized.
alter table public.tree_reports
  add column if not exists species text;

alter table public.tree_reports
  add column if not exists species_scientific text;

alter table public.tree_reports
  add column if not exists species_confidence double precision;

notify pgrst, 'reload schema';
