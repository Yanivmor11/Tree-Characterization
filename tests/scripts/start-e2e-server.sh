#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT/urban_tree"

exec flutter run -d web-server \
  --web-port="${E2E_WEB_PORT:-8080}" \
  --dart-define-from-file=secrets.json \
  --dart-define=BLOCK_SUBMIT_IF_LOW_ACCURACY=false \
  --dart-define=E2E_SEMANTICS=true
