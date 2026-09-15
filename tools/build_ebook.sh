#!/usr/bin/env bash
# Sestaví e-knihu LOFT z kanonické verze _finalni.md do dist/LOFT.mobi (a .epub).
# Reprodukovatelné: vyžaduje python3+markdown a calibre (ebook-convert).
set -euo pipefail
cd "$(dirname "$0")/.."

SRC="_finalni.md"
BUILD="build"
OUT="dist"
mkdir -p "$BUILD" "$OUT"

TITLE="LOFT"
AUTHOR="${LOFT_AUTHOR:-Neznámý autor}"
LANG="cs"

# 1) Markdown -> XHTML (nadpisy ##, kurzíva, oddělovače scén)
python3 - "$SRC" "$BUILD/loft.xhtml" "$TITLE" <<'PY'
import sys, markdown
src, out, title = sys.argv[1], sys.argv[2], sys.argv[3]
text = open(src, encoding="utf-8").read()
body = markdown.markdown(text, extensions=["extra", "sane_lists"], output_format="xhtml")
# oddělovače scén: <hr/> -> vycentrovaná hvězdička (na Kindle čitelnější než čára)
body = body.replace("<hr />", '<p class="sep">✳ ✳ ✳</p>').replace("<hr/>", '<p class="sep">✳ ✳ ✳</p>')
css = """
body { font-family: serif; line-height: 1.5; margin: 0 5%; }
h1 { text-align: center; margin-top: 30%; font-size: 2.1em; letter-spacing: .12em; }
h1 + p { text-align: center; font-style: italic; color: #444; margin-top: .6em; }
h2 { page-break-before: always; text-align: center; margin: 2.2em 0 1.2em; font-size: 1.35em; font-weight: normal; letter-spacing: .04em; }
p { margin: 0; text-indent: 1.3em; text-align: justify; }
p.sep { text-indent: 0; text-align: center; margin: 1.1em 0; letter-spacing: .4em; color: #666; }
"""
html = ('<?xml version="1.0" encoding="utf-8"?>\n'
        '<html xmlns="http://www.w3.org/1999/xhtml" lang="cs"><head>'
        '<meta charset="utf-8"/><title>%s</title><style>%s</style></head>'
        '<body>%s</body></html>' % (title, css, body))
open(out, "w", encoding="utf-8").write(html)
print("XHTML:", out, "bajtů:", len(html.encode("utf-8")))
PY

# 2) XHTML -> MOBI (KF8+MOBI6), automatický obsah z ## kapitol, každá na novou stránku
# ebook-convert vyžaduje pořadí:  vstup  výstup  [volby]
OPTS=( --title "$TITLE" --authors "$AUTHOR" --language "$LANG"
  --chapter "//h:h2" --chapter-mark pagebreak
  --level1-toc "//h:h2" --toc-title "Obsah"
  --page-breaks-before "//h:h2" --pretty-print )

QT_QPA_PLATFORM=offscreen ebook-convert "$BUILD/loft.xhtml" "$OUT/LOFT.mobi" "${OPTS[@]}" --mobi-file-type both
QT_QPA_PLATFORM=offscreen ebook-convert "$BUILD/loft.xhtml" "$OUT/LOFT.epub" "${OPTS[@]}" >/dev/null 2>&1 || true

echo "Hotovo:"
ls -l "$OUT"/LOFT.mobi "$OUT"/LOFT.epub 2>/dev/null || true
