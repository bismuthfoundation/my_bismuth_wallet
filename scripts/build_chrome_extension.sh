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

# Extension pages should not point at the Chrome extension manifest as if it
# were a web app manifest, and they should not try to register Flutter's page
# service worker. Chrome already manages the MV3 background service worker.
python3 - <<'PY' "$EXTENSION_DIR/index.html" "$EXTENSION_DIR/flutter_bootstrap.js"
from pathlib import Path
import re
import sys

index_path = Path(sys.argv[1])
bootstrap_path = Path(sys.argv[2])

index_html = index_path.read_text()
index_html = index_html.replace('\n  <link rel="manifest" href="manifest.json">', '')
index_path.write_text(index_html)

bootstrap_js = bootstrap_path.read_text()
bootstrap_js = re.sub(
    r'\nconst serviceWorkerVersion = .*?;\n',
    '\n',
    bootstrap_js,
    flags=re.S,
)
bootstrap_js = re.sub(
    r'\n\s*serviceWorkerSettings:\s*\{\s*serviceWorkerVersion,\s*\},',
    '',
    bootstrap_js,
    flags=re.S,
)
bootstrap_path.write_text(bootstrap_js)
PY

sed "s/__VERSION__/$EXTENSION_VERSION/" \
  "$ROOT_DIR/chrome_extension/manifest.json" \
  > "$EXTENSION_DIR/manifest.json"

printf 'Chrome extension bundle written to %s\n' "$EXTENSION_DIR"
