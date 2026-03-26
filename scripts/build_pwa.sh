#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

cd "$ROOT_DIR"

flutter build web \
  -t lib/web_main.dart \
  --csp \
  --dart-define=FLUTTER_WEB_CANVASKIT_URL=canvaskit/ \
  "$@"

printf 'Hosted PWA bundle written to %s/build/web\n' "$ROOT_DIR"
