-- ============================================================================
-- AI audit fields backfill (idempotent)
-- ============================================================================
-- Ensures ai_suggestion_json and insights_text exist for Vision AI audit trail.
-- Depends on: 20260413100000_gamification_platform.sql
-- ============================================================================
alter table public.tree_reports
  add column if not exists ai_suggestion_json jsonb;

alter table public.tree_reports
  add column if not exists insights_text text;
