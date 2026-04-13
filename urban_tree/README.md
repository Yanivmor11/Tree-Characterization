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

## Auth and OAuth setup

UrbanTree uses Supabase Auth with:
- Email/password
- Google OAuth

Apple Sign-In is intentionally disabled for now.

### Supabase CLI deployment commands

Run from `urban_tree/`:

```bash
supabase login
supabase link --project-ref <your_project_ref>
supabase db push
```

If your team uses explicit migration apply workflows:

```bash
supabase migration up
```

### Google provider configuration

In Supabase dashboard:
1. Open `Authentication` -> `Providers` -> `Google`.
2. Enable Google provider.
3. Set Google OAuth client ID + client secret.
4. Add redirect URL(s):
   - Supabase callback: `https://<your-project-ref>.supabase.co/auth/v1/callback`
   - Flutter local callback (mobile deep link): `io.supabase.flutter://login-callback/`
5. Save and test sign-in from the app.

### Client-side notes

- Ensure `SUPABASE_URL` and `SUPABASE_ANON_KEY` are configured in `urban_tree/.env` (or `--dart-define-from-file` on web).
- Google OAuth will fail if redirect URLs are missing or if credentials belong to a different Google Cloud project.
