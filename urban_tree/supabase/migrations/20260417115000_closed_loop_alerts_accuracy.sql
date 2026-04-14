-- Closed-loop hardening: generate pest hotspots from reports and enforce GPS precision.

create or replace function public.tree_report_closed_loop_after_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  source_key text;
begin
  if new.accuracy_meters is not null and new.accuracy_meters > 2 then
    raise exception 'GPS accuracy %m exceeds required maximum of 2m', new.accuracy_meters;
  end if;

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
