-- Species standardization + fuzzy matching support (service-only source of truth).
create extension if not exists pg_trgm;

alter table public.tree_reports
  add column if not exists species text;

alter table public.tree_reports
  add column if not exists species_scientific text;

create index if not exists tree_reports_ai_suggestion_json_gin_idx
  on public.tree_reports using gin (ai_suggestion_json jsonb_path_ops);

create index if not exists tree_reports_insights_text_trgm_idx
  on public.tree_reports using gin ((coalesce(insights_text, '')) gin_trgm_ops);

create index if not exists tree_reports_species_trgm_idx
  on public.tree_reports using gin (lower(species) gin_trgm_ops);

create index if not exists tree_reports_species_scientific_trgm_idx
  on public.tree_reports using gin (lower(species_scientific) gin_trgm_ops);

create or replace function public.normalize_scientific_name(name_input text)
returns text
language sql
immutable
as $$
  select case
    when name_input is null then null
    else
      concat_ws(
        ' ',
        initcap(split_part(lower(regexp_replace(trim(name_input), '\s+', ' ', 'g')), ' ', 1)),
        nullif(split_part(lower(regexp_replace(trim(name_input), '\s+', ' ', 'g')), ' ', 2), ''),
        nullif(split_part(lower(regexp_replace(trim(name_input), '\s+', ' ', 'g')), ' ', 3), '')
      )
  end
$$;

create or replace function public.standardize_tree_reports_species()
returns trigger
language plpgsql
as $$
declare
  normalized_common text;
  normalized_scientific text;
  best_common text;
  best_scientific text;
begin
  if new.species is not null then
    normalized_common := initcap(lower(regexp_replace(trim(new.species), '\s+', ' ', 'g')));
    if normalized_common = '' then
      new.species := null;
    else
      select tr.species
      into best_common
      from public.tree_reports tr
      where tr.species is not null
        and trim(tr.species) <> ''
      order by similarity(lower(tr.species), lower(normalized_common)) desc
      limit 1;

      if best_common is not null
         and similarity(lower(best_common), lower(normalized_common)) >= 0.72 then
        new.species := best_common;
      else
        new.species := normalized_common;
      end if;
    end if;
  end if;

  if new.species_scientific is not null then
    normalized_scientific := public.normalize_scientific_name(new.species_scientific);
    if normalized_scientific = '' then
      new.species_scientific := null;
    else
      select tr.species_scientific
      into best_scientific
      from public.tree_reports tr
      where tr.species_scientific is not null
        and trim(tr.species_scientific) <> ''
      order by similarity(lower(tr.species_scientific), lower(normalized_scientific)) desc
      limit 1;

      if best_scientific is not null
         and similarity(lower(best_scientific), lower(normalized_scientific)) >= 0.82 then
        new.species_scientific := best_scientific;
      else
        new.species_scientific := normalized_scientific;
      end if;
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists tree_reports_species_standardization on public.tree_reports;
create trigger tree_reports_species_standardization
before insert or update on public.tree_reports
for each row execute procedure public.standardize_tree_reports_species();
