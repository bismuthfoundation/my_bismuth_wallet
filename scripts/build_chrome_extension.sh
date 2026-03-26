#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WEB_BUILD_DIR="$ROOT_DIR/build/web"
EXTENSION_DIR="$ROOT_DIR/build/chrome_extension"
EXTENSION_VERSION="$(awk '/^version:/ { split($2, parts, "+"); print parts[1]; exit }' "$ROOT_DIR/pubspec.yaml")"

cd "$ROOT_DIR"

flutter build web \
  -t lib/web_main.dart \
  --csp \
  --no-wasm-dry-run \
  --dart-define=FLUTTER_WEB_CANVASKIT_URL=canvaskit/ \
  "$@"

rm -rf "$EXTENSION_DIR"
mkdir -p "$EXTENSION_DIR"

rsync -a "$WEB_BUILD_DIR"/ "$EXTENSION_DIR"/
rsync -a \
  --exclude 'manifest.json' \
  "$ROOT_DIR/chrome_extension"/ "$EXTENSION_DIR"/
sed "s/__VERSION__/$EXTENSION_VERSION/" \
  "$ROOT_DIR/chrome_extension/manifest.json" \
  > "$EXTENSION_DIR/manifest.json"

printf 'Chrome extension bundle written to %s\n' "$EXTENSION_DIR"
