#!/usr/bin/env bash
# Deploy UrbanTree Supabase migrations, secrets, and Edge Functions.
# No global install required: this script uses `npx supabase@latest` when `supabase` is missing.
#
# Usage:
#   1) Put real values in urban_tree/.env (SUPABASE_URL=https://<ref>.supabase.co) — ref is auto-detected, or:
#      export SUPABASE_PROJECT_REF=<ref>   # from Dashboard URL …/project/<ref>
#   2) Auth for CLI (pick one):
#      npx supabase@latest login
#      — or set SUPABASE_ACCESS_TOKEN (Dashboard → Account → Access Tokens) in the shell or in .env (gitignored).
#   3) First-time link / db push may need: export SUPABASE_DB_PASSWORD='…'
#   ./scripts/supabase_backend_deploy.sh
#
# Optional (if all three are set, runs `supabase secrets set`):
#   OPENAI_API_KEY  SUPABASE_SERVICE_ROLE_KEY  DATA_QUALITY_CRON_SECRET
#
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Read KEY=value from .env (first match). Names must be fixed literals (no user-controlled key).
load_dotenv_value() {
  local key="$1"
  local line v
  [[ -f "$ROOT/.env" ]] || return 1
  line="$(grep -E "^[[:space:]]*${key}=" "$ROOT/.env" | head -1 || true)"
  [[ -n "$line" ]] || return 1
  if [[ "$line" =~ ^[[:space:]]*${key}[[:space:]]*=[[:space:]]*(.*)$ ]]; then
    v="${BASH_REMATCH[1]}"
    v="${v#\"}"
    v="${v%\"}"
    v="${v#\'}"
    v="${v%\'}"
    v="${v#"${v%%[![:space:]]*}"}"
    v="${v%"${v##*[![:space:]]}"}"
    printf '%s' "$v"
    return 0
  fi
  return 1
}

# Load SUPABASE_URL from .env if not already in the environment.
if [[ -z "${SUPABASE_URL:-}" ]]; then
  v="$(load_dotenv_value SUPABASE_URL)" && SUPABASE_URL="$v" && export SUPABASE_URL
fi

# CLI personal access token (optional alternative to `supabase login`).
if [[ -z "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
  v="$(load_dotenv_value SUPABASE_ACCESS_TOKEN)" && SUPABASE_ACCESS_TOKEN="$v" && export SUPABASE_ACCESS_TOKEN
fi

if [[ -z "${SUPABASE_PROJECT_REF:-}" && -n "${SUPABASE_URL:-}" ]]; then
  if [[ "$SUPABASE_URL" =~ ^https?://([a-z0-9]+)\.supabase\.co/?$ ]]; then
    SUPABASE_PROJECT_REF="${BASH_REMATCH[1]}"
    export SUPABASE_PROJECT_REF
    echo "Using SUPABASE_PROJECT_REF=$SUPABASE_PROJECT_REF (from SUPABASE_URL)" >&2
  fi
fi

if [[ -z "${SUPABASE_PROJECT_REF:-}" || "$SUPABASE_PROJECT_REF" == "YOUR_PROJECT_REF" ]]; then
  cat >&2 <<'MSG'
Missing project ref. Do one of the following:

  A) In urban_tree/.env set a real URL:
       SUPABASE_URL=https://abcdefghijklmnop.supabase.co
     (the part before .supabase.co is your project ref), then run this script again.

  B) Or export explicitly:
       export SUPABASE_PROJECT_REF=abcdefghijklmnop

Log in without installing the CLI globally:
       npx supabase@latest login

MSG
  exit 1
fi

SUPABASE_BIN=(supabase)
if ! command -v supabase &>/dev/null; then
  SUPABASE_BIN=(npx --yes supabase@latest)
  echo "Using npx supabase@latest (install CLI for faster runs: https://supabase.com/docs/guides/cli)" >&2
fi

LINK_ARGS=(--project-ref "$SUPABASE_PROJECT_REF" --yes)
PUSH_ARGS=(--yes)
if [[ -n "${SUPABASE_DB_PASSWORD:-}" ]]; then
  LINK_ARGS+=(-p "$SUPABASE_DB_PASSWORD")
  PUSH_ARGS+=(-p "$SUPABASE_DB_PASSWORD")
fi

echo "==> Linking project (idempotent)"
"${SUPABASE_BIN[@]}" link "${LINK_ARGS[@]}"

echo "==> Pushing database migrations"
"${SUPABASE_BIN[@]}" db push "${PUSH_ARGS[@]}"

if [[ -n "${OPENAI_API_KEY:-}" && -n "${SUPABASE_SERVICE_ROLE_KEY:-}" && -n "${DATA_QUALITY_CRON_SECRET:-}" ]]; then
  echo "==> Setting Edge secrets"
  "${SUPABASE_BIN[@]}" secrets set \
    --project-ref "$SUPABASE_PROJECT_REF" \
    OPENAI_API_KEY="$OPENAI_API_KEY" \
    SUPABASE_SERVICE_ROLE_KEY="$SUPABASE_SERVICE_ROLE_KEY" \
    DATA_QUALITY_CRON_SECRET="$DATA_QUALITY_CRON_SECRET"
else
  echo "==> Skipping secrets (set OPENAI_API_KEY, SUPABASE_SERVICE_ROLE_KEY, DATA_QUALITY_CRON_SECRET to enable)."
fi

echo "==> Deploying Edge Functions"
for fn in openai-suggest openai-tree-insights data-quality-weekly; do
  "${SUPABASE_BIN[@]}" functions deploy "$fn" \
    --project-ref "$SUPABASE_PROJECT_REF" \
    --use-api
done

cat <<EOF

==> Dashboard (manual)
  - Authentication → Providers → Anonymous: enable (app uses signInAnonymously).
  - Storage: confirm bucket tree-report-media exists (created by initial migration).
  - Cron: run scripts/schedule_data_quality_weekly.sql in SQL Editor after Vault secrets (see file header),
    or configure an equivalent HTTP trigger with header x-data-quality-secret.

==> Verify SQL (optional)
  select pest_code, latitude, longitude from public.pest_hotspots where source = 'seed';
  select id, public from storage.buckets where id = 'tree-report-media';

EOF
