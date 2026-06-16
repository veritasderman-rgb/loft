# Autonomní redakční systém pro Claude Code

Sestava, která sama projede rukopis v opakovaných cyklech a vyladí ho po
vrstvách. Běží hands-off, nedestruktivně (na git větvi, vše commituje
a loguje), takže nic není nevratné a nemusíš během běhu nic rozhodovat.

## Co je v balíčku

- `CLAUDE.md` — mozek celého procesu: pořadí vrstev, smyčka, pravidla.
- `agents/sefredaktor.md` — orchestrátor; řídí cyklus a deleguje.
- `agents/konzistence.md` — bible rukopisu + kontrola soudržnosti.
- `agents/klise-lovec.md` — klišé a mrtvá zesilovadla.
- `agents/smysly.md` — smyslová konkrétnost.
- `agents/vnitrni-hlas.md` — psychologická pravda, sebepoznání.
- `agents/dialog.md` — přirozenost a podtext dialogu.
- `agents/rytmus.md` — kadence a tempo.
- `agents/hlas-strazce.md` — pojistka proti uhlazení; právo veta.

## Instalace (jednou)

1. Vytvoř si složku projektu a dej do ní rukopis:
   ```
   muj-roman/
     rukopis/                ← sem rukopis (jeden .md/.txt, nebo kapitoly)
   ```
2. Zkopíruj `CLAUDE.md` do kořene projektu (`muj-roman/CLAUDE.md`).
3. Zkopíruj celou složku `agents/` do `muj-roman/.claude/agents/`.
   (Tečka na začátku `.claude` musí zůstat.)
4. V kořeni projektu spusť `git init`, pokud tam git ještě není.

## Spuštění

V terminálu v kořeni projektu:

```
cd muj-roman
claude
```

a do Claude napiš jediný příkaz:

```
Spusť kompletní redakci podle CLAUDE.md.
```

Případně rovnou jako orchestrátora:

```
claude --agent sefredaktor
```

Pak už jen čekáš. Systém založí větev, rozdělí rukopis, projede vrstvy,
zapojí strážce hlasu, vyhodnotí konvergenci, případně přidá další cyklus
(max. 3) a na konci spojí finál a napíše krátké shrnutí.

## Po doběhnutí

- Finál: `rukopis/_finalni.md`
- Co se měnilo a proč: `REDAKCE-LOG.md`
- Bible rukopisu: `rukopis/_bible.md`
- Vrátit cokoli zpět: `git log` → `git revert <commit>` nebo
  `git checkout main -- <soubor>`.

## Když chceš ještě jeden průchod (goal)

I po konvergenci můžeš vynutit další cyklus:

```
goal: ještě jeden cyklus
```

## Poznámky

- Modely v hlavičkách (`opus`/`sonnet`) můžeš změnit; orchestrátor a citlivé
  vrstvy (vnitřní hlas, strážce) jedou na opus kvůli jemnému úsudku, zbytek
  na sonnet kvůli rychlosti.
- Tools jsou u každého subagenta omezené na nutné minimum. Když chceš, aby
  některý mohl víc, uprav řádek `tools:` v jeho hlavičce.
- Subagenty můžeš spravovat i příkazem `/agents` přímo v Claude Code.
