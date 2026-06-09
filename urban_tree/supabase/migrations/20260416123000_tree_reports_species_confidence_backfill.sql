-- ============================================================================
-- species_confidence column backfill (idempotent)
-- ============================================================================
-- Stores AI confidence (0–1) for Tier 2 trust score computation.
-- Depends on: 20260416120000_species_standardization_pgtrgm.sql
-- ============================================================================
alter table public.tree_reports
  add column if not exists species text;

alter table public.tree_reports
  add column if not exists species_scientific text;

alter table public.tree_reports
  add column if not exists species_confidence double precision;

notify pgrst, 'reload schema';
