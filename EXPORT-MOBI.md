# Export rukopisu do MOBI

## Požadavky

- Bash
- Python 3 s balíčkem `markdown`
- Calibre, konkrétně příkaz `ebook-convert`

Na Ubuntu lze závislosti nainstalovat například:

```bash
sudo apt-get install calibre python3-markdown
```

## Sestavení

```bash
tools/build_ebook.sh
```

Skript ověří, že existuje právě 25 kanonických kapitol, znovu sestaví
`_finalni.md` z `00-titul.md` a `revize/01–25` a vytvoří `dist/LOFT.mobi`.
Kapitoly druhé úrovně se převedou na položky obsahu a začínají na nové
stránce.

Jméno autora titulní strana rukopisu neuvádí, proto ho sestavení nevymýšlí.
Pro finální distribuční soubor je možné metadata doplnit proměnnou:

```bash
BOOK_AUTHOR="Jméno autora" tools/build_ebook.sh
```

## Kontrola

```bash
tools/check_manuscript.py
ebook-meta dist/LOFT.mobi
```

První příkaz kontroluje pořadí kapitol a shodu `_finalni.md` se zdroji.
Druhý vypíše metadata hotového MOBI souboru.
