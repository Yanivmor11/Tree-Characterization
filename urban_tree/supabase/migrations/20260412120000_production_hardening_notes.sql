-- Production hardening (reference migration): apply in a maintenance window after updating the app.
-- Client-side validation in TreeReportValidator is not sufficient for abuse prevention.

-- 1) Minimum photo evidence per mapping protocol (adjust thresholds if product policy changes).
alter table public.tree_reports drop constraint if exists tree_reports_min_whole_photos;
alter table public.tree_reports add constraint tree_reports_min_whole_photos
  check (cardinality(whole_tree_image_urls) >= 1);

alter table public.tree_reports drop constraint if exists tree_reports_min_leaves_photos;
alter table public.tree_reports add constraint tree_reports_min_leaves_photos
  check (cardinality(leaves_image_urls) >= 1);

-- 2) Flower metadata when flower images exist (requires a SQL check on array length).
-- Postgres: use a trigger if check expressions become too complex.

create or replace function public.enforce_flower_metadata()
returns trigger
language plpgsql
as $$
begin
  if cardinality(new.flower_image_urls) > 0 then
    if new.phenological_stage is null or new.flower_abundance is null then
      raise exception 'flower_image_urls requires phenological_stage and flower_abundance';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists tree_reports_flower_metadata on public.tree_reports;
create trigger tree_reports_flower_metadata
  before insert or update on public.tree_reports
  for each row execute procedure public.enforce_flower_metadata();

-- 3) Row Level Security: replace demo policies before production.
-- Example (requires Supabase Auth): only authenticated users may insert; public read optional.
-- drop policy "tree_reports_insert_all" on public.tree_reports;
-- create policy "tree_reports_insert_authenticated" on public.tree_reports
--   for insert to authenticated with check (auth.role() = 'authenticated');

-- 4) Rate limiting: use Edge Function gateway, API gateway, or pg_stat-based monitoring;
--    pure Postgres rate limits typically need a helper table + trigger.

-- 5) Storage: set max upload size in Dashboard; consider private bucket + signed URLs for sensitive deployments.
