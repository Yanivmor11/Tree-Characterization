# CI/CD setup (GitHub Actions + Vercel + Supabase)

Workflows live in [`.github/workflows/`](../.github/workflows/).

## What runs automatically

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci.yml` | Every push/PR to `main` | `flutter analyze`, `flutter test`, web build smoke |
| `deploy-vercel.yml` | Push to `main` (urban_tree changes) | Build Flutter web + deploy to **https://urbantree.vercel.app** |
| `deploy-supabase.yml` | Push changing `supabase/functions` or `migrations` | Deploy Edge Functions; migrations only on manual dispatch |
| `e2e.yml` | Weekly (Mon 05:00 UTC) or manual | Playwright against production |

## Required GitHub secrets

Add in **GitHub → Repository → Settings → Secrets and variables → Actions**.

### Vercel (`deploy-vercel.yml`)

| Secret | Value |
|--------|--------|
| `VERCEL_TOKEN` | [Vercel account token](https://vercel.com/account/settings/tokens) |
| `VERCEL_ORG_ID` | `team_Fj2BiIxZLO1qq7MaZxhZ52H0` |
| `VERCEL_PROJECT_ID` | `prj_ygwRinGIEdYMELOPqbwOLuW9GYfT` |
| `SUPABASE_URL` | Same as production `.env` |
| `SUPABASE_ANON_KEY` | Publishable anon key |
| `OPENAI_API_KEY` | Optional (web uses Edge Functions) |

### Supabase (`deploy-supabase.yml`)

| Secret | Value |
|--------|--------|
| `SUPABASE_ACCESS_TOKEN` | [Supabase personal access token](https://supabase.com/dashboard/account/tokens) |
| `SUPABASE_PROJECT_REF` | Subdomain before `.supabase.co` |
| `SUPABASE_DB_PASSWORD` | DB password (manual migration job only) |

### E2E (`e2e.yml`)

| Secret | Value |
|--------|--------|
| `E2E_TEST_EMAIL` | Dedicated test user email in Supabase Auth |
| `E2E_TEST_PASSWORD` | Test user password |

## Vercel project settings (dashboard)

- **Root Directory:** `urban_tree` **or** repo root (root `vercel.json` delegates to `urban_tree/`).
- **Production URL to share:** https://urbantree.vercel.app
- **Environment variables (Production):** `SUPABASE_URL`, `SUPABASE_ANON_KEY`, optional `APP_ENV=prod`.

## Supabase CORS

In Supabase → **Project Settings → API**, allow:

- `https://urbantree.vercel.app`
- `http://localhost:*` (local dev)

## Manual deploy (fallback)

```bash
cd urban_tree
npx vercel --prod   # needs `vercel login` once
./scripts/supabase_backend_deploy.sh
```
