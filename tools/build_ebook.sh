#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
DIST="$ROOT/dist"
FINAL="$ROOT/_finalni.md"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

mapfile -t CHAPTERS < <(find "$ROOT/revize" -maxdepth 1 -type f -name '*.md' | sort)
if [[ ${#CHAPTERS[@]} -ne 25 ]]; then
  echo "Očekáváno 25 kapitol, nalezeno ${#CHAPTERS[@]}." >&2
  exit 1
fi

mkdir -p "$DIST"
cat "$ROOT/00-titul.md" "${CHAPTERS[@]}" > "$FINAL"

METADATA=(--title "LOFT" --language cs)
if [[ -n "${BOOK_AUTHOR:-}" ]]; then
  METADATA+=(--authors "$BOOK_AUTHOR")
fi

/usr/bin/python3 - "$FINAL" "$TMP/LOFT.html" <<'PY'
from pathlib import Path
import markdown
import sys

source, target = map(Path, sys.argv[1:])
body = markdown.markdown(
    source.read_text(encoding="utf-8"),
    extensions=["extra", "smarty", "toc"],
)
target.write_text(
    "<!doctype html><html lang=\"cs\"><head><meta charset=\"utf-8\">"
    "<title>LOFT</title></head><body>" + body + "</body></html>",
    encoding="utf-8",
)
PY

ebook-convert "$TMP/LOFT.html" "$DIST/LOFT.mobi" \
  "${METADATA[@]}" \
  --comments "Příběh Saši Kratochvílové, která v sedm ráno věděla vše a o půlnoci nevěděla nic." \
  --extra-css "$ROOT/tools/ebook.css" \
  --chapter "//h:h2" \
  --level1-toc "//h:h2" \
  --page-breaks-before "//h:h2"

echo "Vytvořeno: $FINAL"
echo "Vytvořeno: $DIST/LOFT.mobi"
