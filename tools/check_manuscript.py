#!/usr/bin/env python3
"""Deterministické produkční kontroly kanonického rukopisu LOFT."""

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
chapters = sorted((ROOT / "revize").glob("*.md"))
errors: list[str] = []

if len(chapters) != 25:
    errors.append(f"Očekáváno 25 kapitol, nalezeno {len(chapters)}")

for expected, path in enumerate(chapters, 1):
    if not path.name.startswith(f"{expected:02d}-"):
        errors.append(f"Chybné pořadí: {path.name} na pozici {expected}")

    text = path.read_text(encoding="utf-8")
    if "\r" in text:
        errors.append(f"{path}: obsahuje CRLF")
    if "\t" in text:
        errors.append(f"{path}: obsahuje tabulátor")
    if re.search(r"[ \t]+$", text, re.MULTILINE):
        errors.append(f"{path}: koncové mezery")
    if not text.startswith("## "):
        errors.append(f"{path}: chybí nadpis druhé úrovně")
    if text.count("## ") != 1:
        errors.append(f"{path}: očekáván právě jeden kapitolový nadpis")
    if re.search(r" {2,}[,.!?;:]", text):
        errors.append(f"{path}: vícenásobná mezera před interpunkcí")
    if "nádstavba" in text:
        errors.append(f"{path}: překlep „nádstavba“")

final = (ROOT / "_finalni.md").read_text(encoding="utf-8")
expected_final = (ROOT / "00-titul.md").read_text(encoding="utf-8") + "".join(
    path.read_text(encoding="utf-8") for path in chapters
)
if final != expected_final:
    errors.append("_finalni.md neodpovídá titulní straně + revize/01–25")

if errors:
    print("\n".join(f"CHYBA: {error}" for error in errors), file=sys.stderr)
    raise SystemExit(1)

word_count = len(final.split())
print(f"OK: 25 kapitol, synchronní _finalni.md, {word_count} slov")
