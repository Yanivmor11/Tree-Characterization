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

## Vercel (production web)

The repo includes [`vercel.json`](vercel.json) and [`scripts/vercel_build.sh`](scripts/vercel_build.sh) so Vercel runs a real **`flutter build web`** and publishes **`build/web`** (fixes empty deployments and `404 NOT_FOUND` on the live URL).

### Project settings

- **Root Directory:** `urban_tree` (if the Vercel project is linked to this monorepo).
- **Framework preset:** Other (Vercel reads `buildCommand` / `outputDirectory` from `vercel.json`).

### Required environment variables (Production)

Set these in Vercel → Project → **Settings** → **Environment Variables** → **Production**:

| Name | Notes |
|------|--------|
| `SUPABASE_URL` | Same as in `.env` |
| `SUPABASE_ANON_KEY` | Publishable anon key |
| `APP_ENV` | Optional; default `prod` if unset |
| `OPENAI_API_KEY` | Optional; web assistant uses Edge Functions, so often omitted |

Without `SUPABASE_URL` and `SUPABASE_ANON_KEY`, the build **fails on purpose** (release web cannot read `.env` in the browser).

### Supabase CORS

In Supabase → **Project Settings** → **API**, add your production site origin to allowed **CORS** origins (e.g. `https://urbantree.vercel.app`).

### Deploy

From `urban_tree/`:

```bash
npx vercel --prod
```
