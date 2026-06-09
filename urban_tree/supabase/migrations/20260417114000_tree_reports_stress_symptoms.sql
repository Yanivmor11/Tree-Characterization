-- ============================================================================
-- stress_symptoms array — foliar stress + closed-loop pest detection
-- ============================================================================
-- pest_damage value triggers pest_hotspot auto-creation (500 m radius).
-- Depends on: 20260413100000_gamification_platform.sql
-- ============================================================================

alter table public.tree_reports
  add column if not exists stress_symptoms text[] not null default '{}';

alter table public.tree_reports
  drop constraint if exists tree_reports_stress_symptoms_check;

alter table public.tree_reports
  add constraint tree_reports_stress_symptoms_check check (
    stress_symptoms <@ array[
      'chlorosis',
      'necrosis',
      'wilting',
      'leaf_spot',
      'defoliation',
      'gummosis',
      'pest_damage',
      'none',
      'other'
    ]::text[]
  );

create index if not exists tree_reports_stress_symptoms_idx
  on public.tree_reports using gin (stress_symptoms);
