#!/usr/bin/env bash
# Run from repo root (Tree-Characterization). Delegates to urban_tree.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec "$ROOT/urban_tree/scripts/build_android_prod.sh" "$@"
