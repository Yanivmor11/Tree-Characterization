-- ============================================================================
-- hazard_assessment — municipal asset risk (low/medium/high)
-- ============================================================================
-- Captured in wizard step 0 for urban forest asset management integration.
-- Note: shares 20260417120000 timestamp prefix with restore_granular migration.
-- ============================================================================

alter table public.tree_reports
  add column if not exists hazard_assessment text not null default 'low';

alter table public.tree_reports
  drop constraint if exists tree_reports_hazard_assessment_check;

alter table public.tree_reports
  add constraint tree_reports_hazard_assessment_check check (
    hazard_assessment in ('low', 'medium', 'high')
  );

create index if not exists tree_reports_hazard_assessment_idx
  on public.tree_reports (hazard_assessment);
