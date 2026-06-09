-- ============================================================================
-- Closed-loop feedback — GPS hard gate + pest hotspot auto-creation
-- ============================================================================
-- Server ALWAYS rejects accuracy_meters > 2 (cadastral-grade requirement).
-- pest_damage stress symptom → 500 m hotspot overlay for neighborhood alerts.
-- Independent of client BLOCK_SUBMIT_IF_LOW_ACCURACY flag.
--
-- Depends on: 20260413100000_gamification_platform.sql, stress_symptoms column
-- ============================================================================

create or replace function public.tree_report_closed_loop_after_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  source_key text;
begin
  -- Hard scientific gate: 2 m max uncertainty for public/private land distinction.
  if new.accuracy_meters is not null and new.accuracy_meters > 2 then
    raise exception 'GPS accuracy %m exceeds required maximum of 2m', new.accuracy_meters;
  end if;

  -- Citizen-reported pest damage seeds a 500 m alert zone for map overlays.
  if new.stress_symptoms @> array['pest_damage']::text[] then
    source_key := 'report:' || new.id::text;
    insert into public.pest_hotspots (
      pest_code,
      label,
      latitude,
      longitude,
      radius_m,
      severity,
      source,
      active
    )
    values (
      'red_palm_weevil',
      'Localized Red Palm Weevil alert',
      new.latitude,
      new.longitude,
      500,
      3,
      source_key,
      true
    )
    on conflict do nothing;
  end if;

  return new;
end;
$$;

drop trigger if exists tree_reports_closed_loop_after_insert on public.tree_reports;
create trigger tree_reports_closed_loop_after_insert
  after insert on public.tree_reports
  for each row
  execute procedure public.tree_report_closed_loop_after_insert();
