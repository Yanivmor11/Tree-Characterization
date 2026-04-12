# UrbanTree deployment checklist

Use this before Google Play, Apple App Store, and production web hosting.

## Identifiers and signing

- [ ] **Android** `applicationId` / namespace: `il.co.urbantree.app` (change in `android/app/build.gradle.kts` if you use a different legal entity).
- [ ] **Android** Create an upload keystore; copy `android/key.properties.example` → `key.properties`; never commit keystore or passwords.
- [ ] **Android** Build store bundle:  
  `flutter build appbundle --flavor prod --release --dart-define-from-file=secrets.json`  
  Dev/internal: `--flavor dev` → `il.co.urbantree.app.dev`.
- [ ] **iOS** Bundle ID: `il.co.urbantree.app` in Xcode; App Store Connect record matches.
- [ ] **iOS** Run `pod install` in `ios/` after `flutter pub get` (generates/updates `Podfile.lock` for CI). Distribution signing in Xcode (Release).
- [ ] **iOS** `ITSAppUsesNonExemptEncryption` is `false` in `Info.plist` unless you use non-exempt crypto (then file Apple documentation).

## Secrets (no `.env` in assets)

- [ ] Copy `secrets.json.example` → `secrets.json` (gitignored). Fill `SUPABASE_URL`, `SUPABASE_ANON_KEY`, optional `OPENAI_API_KEY`, `APP_ENV=prod`.
- [ ] CI: inject `secrets.json` or equivalent CI variables into `--dart-define-from-file`.
- [ ] **Web + assistant**: Deploy Edge Function `openai-suggest` and set `OPENAI_API_KEY` in Supabase secrets (see `supabase/functions/openai-suggest/README.md`). Web does **not** use a client OpenAI key.
- [ ] Optional production gate: set `"BLOCK_SUBMIT_IF_LOW_ACCURACY": "true"` in `secrets.json` to reject reports when GPS uncertainty &gt; 2 m.

### Helper scripts

From **repository root** (`Tree-Characterization`): `./scripts/build_web_prod.sh` and `./scripts/build_android_prod.sh` (they call into `urban_tree/scripts/`). From **`urban_tree/`**: `./scripts/build_web_prod.sh` works the same. Both require `urban_tree/secrets.json` unless you set `SECRETS_FILE=/path/to.json`. Web subpath: `BASE_HREF=/app/ ./scripts/build_web_prod.sh`. Android needs `ANDROID_HOME` (or `ANDROID_SDK_ROOT`) pointing at your SDK.

## Web hosting

- [ ] Build: `flutter build web --release` (subpath: add `--base-href=/your-path/`).
- [ ] **Supabase**: Dashboard → Project Settings → API → add your production **origin** (e.g. `https://trees.example.com`) to allowed CORS origins.
- [ ] Serve `build/web/` over HTTPS; confirm REST, Auth, Storage, and Functions from the browser.

## Store policy and privacy

- [ ] Host a **privacy policy** (use `docs/PRIVACY_POLICY.template.md` as a starting point; have counsel review).
- [ ] **Google Play** Data safety form: see `docs/DATA_SAFETY_INVENTORY.md`.
- [ ] **Apple** App Privacy labels: same inventory; clarify tree ecological “health” is not human health data.
- [ ] Screenshots, feature graphic, age rating, and export compliance questionnaires completed.

## Supabase backend (CLI)

- [ ] Install [Supabase CLI](https://supabase.com/docs/guides/cli) (or use `npx supabase@latest`).
- [ ] `supabase login` then set `SUPABASE_PROJECT_REF` (and `SUPABASE_DB_PASSWORD` if the CLI asks for the DB password on first link/push). From `urban_tree/`: `./scripts/supabase_backend_deploy.sh` (links, `db push`, optional secrets, deploys `openai-suggest`, `openai-tree-insights`, `data-quality-weekly` with `--use-api`). Or run the same steps manually per `supabase/functions/openai-suggest/README.md`.
- [ ] Edge secrets: `OPENAI_API_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `DATA_QUALITY_CRON_SECRET` (add `SUPABASE_URL` only if logs show the weekly function cannot read the project URL).
- [ ] Weekly data-quality job: after Vault secrets in `scripts/schedule_data_quality_weekly.sql`, run that SQL in the Dashboard SQL Editor (header `x-data-quality-secret` must match `DATA_QUALITY_CRON_SECRET`).
- [ ] Dashboard → Authentication → Providers → **Anonymous**: enable (required for `signInAnonymously`).
- [ ] Confirm storage bucket `tree-report-media` and policies exist (`supabase/migrations/20260401100000_initial_schema.sql`); set max upload size as needed.
- [ ] Optional: `select * from public.pest_hotspots where source = 'seed';` (Tel Aviv demo hotspot after gamification migration). GPS ≤ 2 m is enforced in the app only when `BLOCK_SUBMIT_IF_LOW_ACCURACY` is true in `secrets.json` (see above); `accuracy_meters` is still stored for analysis.

## Backend hardening

- [ ] Apply production SQL policies: migrations apply auth-scoped `tree_reports` RLS via `20260413100000_gamification_platform.sql` after `20260401100000_initial_schema.sql`.
- [ ] Storage: set max upload size; consider private bucket + signed URLs if needed.

## Branding regeneration

After replacing `assets/images/logo.png`:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Android flavors reminder

This project defines `dev` and `prod` product flavors. Always pass `--flavor` for Android builds, for example:

- `flutter run --flavor dev`
- `flutter build appbundle --flavor prod --release`

iOS does not duplicate Xcode schemes for flavors; use the same bundle ID and pass `--dart-define` / `--dart-define-from-file` for `APP_ENV`.
