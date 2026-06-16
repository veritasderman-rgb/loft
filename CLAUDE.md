# Redakční systém — řízení projektu

Tento soubor řídí autonomní redakci rukopisu. Hlavní sezení (nebo agent
`sefredaktor`) podle něj orchestruje práci a deleguje na subagenty
v `.claude/agents/`. Cílem je dokonalá literární kvalita při zachování
autorova hlasu. **Autor během běhu nic nerozhoduje** — systém pracuje
nedestruktivně, vše commituje a loguje, takže je vše dohledatelné a vratné.

---

## Vstup

Rukopis leží v `rukopis/`. Může to být:
- jeden velký soubor (`.md`, `.txt`, případně převedený z `.docx`), nebo
- už rozdělené kapitoly v `rukopis/kapitoly/`.

Pokud je to jeden velký soubor, **nejdřív ho rozděl** na scény/kapitoly
do `rukopis/kapitoly/` (číslované `01-…`, `02-…`) podle prázdných řádků,
nadpisů nebo přirozených předělů. Každý díl by měl být max. ~2–3 strany,
aby s ním subagent pracoval s plným kontextem. Toto rozdělení je jen
pracovní; finální export se zase spojí.

---

## Nedestruktivní pravidla (platí vždy)

1. **Originál se nikdy nepřepisuje.** Před prvním cyklem:
   `git checkout -b redakce/cyklus-1` (pokud projekt není v gitu, založ ho).
2. **Po každém průchodu jednou vrstvou commitni** s popisnou zprávou,
   např. `redakce(klise): kap. 03 — 7 zásahů`.
3. **Veď `REDAKCE-LOG.md`.** Po každém průchodu připiš: která vrstva, které
   kapitoly, kolik zásahů, 3 nejčastější vzorce, a 2–3 ukázky
   „původní → návrh + proč". Tohle je auditní stopa pro autora — generuje se
   automaticky, autor ji nemusí číst, aby systém běžel.
4. **Žádná cenzura obsahu.** Text je pro dospělé, explicitnost je záměr.
   Subagenti nikdy „neumravňují", neeufemizují, neměkčí.
5. **Nikdy neměň víc vrstev v jednom průchodu.** Jeden subagent = jedna vrstva.

---

## Pořadí vrstev v jednom cyklu

Orchestrátor projíždí rukopis vrstvu po vrstvě. V každé vrstvě deleguje
na příslušného subagenta a nechá ho projít všechny kapitoly. Pořadí:

1. `konzistence` — **nejdřív zmapovat** (jen čte + sepíše bibli rukopisu:
   jména, časová osa, prostor, charakterové detaily) → uloží do
   `rukopis/_bible.md`. Ostatní subagenti tuhle bibli čtou.
2. `klise-lovec` — opotřebované obraty, mrtvá zesilovadla (klišé se hromadí
   nejvíc v erotických pasážích — tam být obzvlášť přísný).
3. `smysly` — smyslová konkrétnost, individualizovaný tělesný detail.
4. `vnitrni-hlas` — psychologická pravdivost, sebepoznání, rozpor mezi tím,
   co postava cítí, a tím, co si myslí, že cítí.
5. `dialog` — přirozenost, podtext, idiolekt postav.
6. `rytmus` — variace délky vět, kadence, tempo odstavců.
7. `hlas-strazce` — **kontrolní vrstva**: projde `git diff` celého cyklu
   a **vrátí** každou změnu, která zploštila autorův hlas, smazala záměrnou
   idiosynkrazii, „učesala" text do průměrnosti nebo ubrala odvahu.
   Tahle vrstva má právo veta nad ostatními.

Po vrstvě 7 znovu spusť `konzistence` v režimu kontroly (ne mapování),
ať edity nerozbily časovou/prostorovou logiku.

---

## Smyčka (goal-style, opakované průchody)

```
cyklus = 1
dokud cyklus <= 3:
    proveď vrstvy 1–7 (vrstvu 1 = kontrola, ne nové mapování, od cyklu 2)
    spočítej "smysluplné zásahy" tohoto cyklu (z REDAKCE-LOG.md)
    commitni cyklus
    pokud smysluplné_zásahy < 0.5 % počtu vět rukopisu:
        # konvergence — text se ustálil, další průchody by jen šuměly
        ukonči smyčku
    cyklus += 1
```

Konvergence (málo zásahů) = signál, že je text vyladěný; další průchody
už jen riskují přeleštění. Strop jsou 3 cykly, ať to neběží donekonečna.

Pokud autor zadá explicitně `goal: ještě jeden cyklus`, přidej jeden
průchod nad rámec konvergence.

---

## Výstup po doběhnutí

1. Spoj kapitoly zpět do `rukopis/_finalni.md`.
2. Do `REDAKCE-LOG.md` připiš závěrečné shrnutí: kolik cyklů, celkem zásahů
   po vrstvách, hlavní vzorce, které se v rukopisu opakovaly (ať je autor
   umí hlídat sám), a seznam pasáží, které subagenti označili jako „silné,
   nesahat".
3. Vypiš autorovi jednu krátkou zprávu: hotovo, kde je finál, kolik cyklů,
   a jak vrátit cokoli zpět (`git log` / `git revert`).

Žádné průběžné dotazy. Systém se ptá jen tehdy, narazí-li na **věcný rozpor
v ději**, který nelze vyřešit bez autora (např. dvě neslučitelné verze
osudu postavy) — to zaloguje a pokračuje ve zbytku, dotaz nechá na konec.
