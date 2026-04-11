# UrbanTree

Flutter client for citizen science tree reporting (OpenStreetMap + Supabase). See `../root/MAPPING_PROTOCOL.md` for field protocol.

## Prerequisites

- Flutter SDK (stable), Chrome (web), Xcode/Android Studio (mobile).
- A Supabase project. Apply `supabase/schema.sql` in the SQL editor, then create the public storage bucket `tree-report-media` if the script could not insert it.
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
