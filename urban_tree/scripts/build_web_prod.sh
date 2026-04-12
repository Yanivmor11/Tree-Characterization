#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Use SECRETS_FILE=/path/to/file.json to override (default: urban_tree/secrets.json).
SECRETS="${SECRETS_FILE:-secrets.json}"
if [[ ! -f "$SECRETS" ]]; then
  echo "Missing secrets file: $SECRETS"
  echo "Create it from the example, then edit values:"
  echo "  cp secrets.json.example secrets.json"
  echo ""
  echo "Or set SECRETS_FILE to an existing JSON file:"
  echo "  SECRETS_FILE=~/secrets/urbantree.json $0"
  exit 1
fi

# Optional subpath: BASE_HREF=/path/ $0  →  --base-href=/path/
# Avoid "${arr[@]}" on an empty array with `set -u` (fails on macOS bash).
if [[ -n "${BASE_HREF:-}" ]]; then
  flutter build web --release --dart-define-from-file="$SECRETS" --base-href="$BASE_HREF"
else
  flutter build web --release --dart-define-from-file="$SECRETS"
fi
