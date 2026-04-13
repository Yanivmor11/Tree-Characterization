#!/usr/bin/env bash
# Build Flutter web on Vercel (Linux). Requires env vars set in the Vercel project:
#   SUPABASE_URL, SUPABASE_ANON_KEY
# Optional: OPENAI_API_KEY, APP_ENV (defaults to prod)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ -z "${SUPABASE_URL:-}" || -z "${SUPABASE_ANON_KEY:-}" ]]; then
  echo "ERROR: Missing SUPABASE_URL or SUPABASE_ANON_KEY."
  echo "Add them in Vercel → Project → Settings → Environment Variables (Production)."
  exit 1
fi

FLUTTER_DIR="${FLUTTER_DIR:-$HOME/flutter_vercel_sdk}"
if [[ ! -x "$FLUTTER_DIR/bin/flutter" ]]; then
  echo "Installing Flutter SDK (stable, shallow clone)..."
  rm -rf "$FLUTTER_DIR"
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_DIR"
fi
export PATH="$FLUTTER_DIR/bin:$PATH"

flutter --version
flutter config --no-analytics
flutter precache --web
flutter pub get

APP_ENV_VALUE="${APP_ENV:-prod}"
OPENAI_VALUE="${OPENAI_API_KEY:-}"

flutter build web --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=APP_ENV="$APP_ENV_VALUE" \
  --dart-define=OPENAI_API_KEY="$OPENAI_VALUE"

echo "Web build complete: $ROOT/build/web"
