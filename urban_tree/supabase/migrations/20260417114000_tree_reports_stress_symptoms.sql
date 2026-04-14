-- Add structured stress symptoms for AI-assisted prefill and research export.

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
