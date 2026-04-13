-- Defensive backfill for environments that missed earlier migration batches.
alter table public.tree_reports
  add column if not exists ai_suggestion_json jsonb;

alter table public.tree_reports
  add column if not exists insights_text text;
