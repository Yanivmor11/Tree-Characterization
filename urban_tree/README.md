# UrbanTree

Flutter client for citizen science tree reporting (OpenStreetMap + Supabase). See `../root/MAPPING_PROTOCOL.md` for field protocol.

## Prerequisites

- Flutter SDK (stable), Chrome (web), Xcode/Android Studio (mobile).
- A Supabase project. Prefer `./scripts/supabase_backend_deploy.sh` (after `supabase login`) or `supabase db push` so migrations apply in order (`20260401100000_initial_schema.sql` replaces a manual `schema.sql` run). You can still paste `supabase/schema.sql` in the SQL Editor for a one-off bootstrap.
- `urban_tree/.env` with `SUPABASE_URL` and `SUPABASE_ANON_KEY` (see `.env.example`).

## Run & test

From this directory (`urban_tree/`):

```bash
flutter pub get
flutter analyze
flutter test
```

**Web (Chrome):**

```bash
flutter run -d chrome
```

Use HTTPS or `localhost` so the browser allows high-accuracy geolocation.

**Mobile over USB:**

```bash
flutter devices
flutter run -d <device_id>
```

Enable developer mode / USB debugging on Android; trust the computer on iOS.

## Land-use GIS

`land_zones` rows are axis-aligned bounding boxes. Classification uses highest `layer_priority`, then the smallest area (narrower box wins in overlaps). Map tints are toggled from the app bar **layers** action.

## Reporting flow

Three steps map to `tree_reports`: whole tree (health, canopy, structure), optional flower/fruit, leaves (condition + damage extent). Images upload to the `tree-report-media` bucket; metadata is inserted in one row after uploads complete.
