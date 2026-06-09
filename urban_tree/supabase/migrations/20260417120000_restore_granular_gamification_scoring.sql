-- ============================================================================
-- Granular gamification scoring — 10 + 15 + 10 + 5 (max 40 points)
-- ============================================================================
-- Motivates physiological completeness: base whole-tree (10), flower detail (+15),
-- leaf detail (+10), GIS auto land-match (+5). Badge grants reward milestone behaviors
-- (first phenology, private land pioneer, city-first bloom, neighborhood watch).
--
-- Reverts temporary flat 25-pt scoring from 20260417113000.
-- Depends on: grant_user_badge() from gamification_badges_hardening migration
-- ============================================================================

create or replace function public.tree_report_gamification_after_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  -- Point breakdown mirrors client ReportScoringService preview in wizard UI.
  base_pts int := 10;   -- whole-tree step always present at submit
  flower_pts int := 0;  -- +15 when reproductive structures photographed
  leaf_pts int := 0;    -- +10 when foliar detail photographed
  land_pts int := 0;    -- +5 when GIS auto-classified land tenure
  total_pts int;
  previous_total int := 0;
  points_delta int := 0;
  profile_city text;
  prior_species_count int;
  neighborhood_count int;
  phenology_count int;
  private_land_count int;
begin
  if new.user_id is null then
    return new;
  end if;

  if cardinality(new.flower_image_urls) > 0 then
    flower_pts := 15;
  end if;

  if cardinality(new.leaves_image_urls) > 0 then
    leaf_pts := 10;
  end if;

  if new.land_type_auto = true then
    land_pts := 5;
  end if;

  total_pts := base_pts + flower_pts + leaf_pts + land_pts;

  select coalesce(rs.total, 0) into previous_total
  from public.report_scores rs
  where rs.report_id = new.id;

  insert into public.report_scores (report_id, points_breakdown, total)
  values (
    new.id,
    jsonb_build_object(
      'base', base_pts,
      'flower_fruit', flower_pts,
      'leaf_detail', leaf_pts,
      'land_use', land_pts
    ),
    total_pts
  )
  on conflict (report_id) do update
    set points_breakdown = excluded.points_breakdown,
        total = excluded.total;

  points_delta := total_pts - previous_total;

  if points_delta <> 0 then
    update public.profiles
    set total_points = greatest(0, total_points + points_delta),
        updated_at = now()
    where id = new.user_id;
  end if;

  select city_slug into profile_city
  from public.profiles
  where id = new.user_id;

  select count(*) into phenology_count
  from public.tree_reports tr
  where tr.user_id = new.user_id
    and tr.phenological_stage in ('bud', 'open', 'fruit');

  if phenology_count = 1 and new.phenological_stage in ('bud', 'open', 'fruit') then
    perform public.grant_user_badge(new.user_id, 'first_blossom_reporter');
  end if;

  select count(*) into private_land_count
  from public.tree_reports tr
  where tr.user_id = new.user_id
    and tr.land_type = 'private';

  if private_land_count = 1 and new.land_type = 'private' then
    perform public.grant_user_badge(new.user_id, 'private_land_pioneer');
  end if;

  if new.species is not null
     and profile_city is not null
     and new.phenological_stage in ('bud', 'open') then
    select count(*) into prior_species_count
    from public.tree_reports tr
    join public.profiles p on p.id = tr.user_id
    where tr.id <> new.id
      and p.city_slug is not distinct from profile_city
      and lower(trim(tr.species)) = lower(trim(new.species))
      and tr.phenological_stage in ('bud', 'open');

    if prior_species_count = 0 then
      perform public.grant_user_badge(new.user_id, 'first_bloom_hunter');
    end if;
  end if;

  select count(*) into neighborhood_count
  from public.tree_reports tr
  where tr.user_id = new.user_id
    and round(tr.latitude::numeric, 3) = round(new.latitude::numeric, 3)
    and round(tr.longitude::numeric, 3) = round(new.longitude::numeric, 3);

  if neighborhood_count >= 5 then
    perform public.grant_user_badge(new.user_id, 'neighborhood_watch');
  end if;

  return new;
end;
$$;
