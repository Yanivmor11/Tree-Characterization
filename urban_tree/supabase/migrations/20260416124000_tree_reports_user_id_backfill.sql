-- ============================================================================
-- user_id ownership backfill (idempotent)
-- ============================================================================
-- Links reports to auth.users for RLS and gamification triggers.
-- Depends on: 20260413100000_gamification_platform.sql
-- ============================================================================
alter table public.tree_reports
  add column if not exists user_id uuid references auth.users (id);

create index if not exists tree_reports_user_id_idx
  on public.tree_reports (user_id);

notify pgrst, 'reload schema';
