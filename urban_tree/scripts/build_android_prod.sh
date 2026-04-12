#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

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

if [[ -z "${ANDROID_HOME:-}" ]] && [[ -z "${ANDROID_SDK_ROOT:-}" ]]; then
  for candidate in "$HOME/Library/Android/sdk" "$HOME/Android/Sdk"; do
    if [[ -d "$candidate" ]]; then
      export ANDROID_HOME="$candidate"
      break
    fi
  done
fi
if [[ -z "${ANDROID_HOME:-}" ]] && [[ -z "${ANDROID_SDK_ROOT:-}" ]]; then
  echo "Warning: ANDROID_HOME / ANDROID_SDK_ROOT is not set. Flutter needs the Android SDK for this build."
  echo "Install Android Studio or cmdline-tools and export ANDROID_HOME, e.g.:"
  echo "  export ANDROID_HOME=\"\$HOME/Library/Android/sdk\""
  echo ""
fi

flutter build appbundle --flavor prod --release --dart-define-from-file="$SECRETS"
