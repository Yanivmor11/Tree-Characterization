-- Relax citizen-science GPS gate: allow typical mobile GNSS accuracy (no 2 m hard block).
-- Pest hotspot seeding on pest_damage is unchanged.

create or replace function public.tree_report_closed_loop_after_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  source_key text;
begin
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
