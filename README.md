# parloku

**Play it:** https://pietroppeter.github.io/parloku/

Parloku is a mini sudoku spelled in letters (a *wordoku*) with words hidden in it.
Fill the 6×6 grid so each of six letters appears once per row, column and 2×3 box, and
so every clue word can be spelled from its numbered cell, one step at a time up, down, left or right.

Here you play by dragging: every letter has a stack of six coloured tiles below the board,
and you drag them up into the cells. The dragging is a small port of
[Declarative Dragging](https://declarative-dragging.github.io/) (Horowitz, Blinn & Heer, UIST 2026):
the code never handles a drop, it only lists the boards a drag can reach.

The game speaks English and Italian (EN / IT switch, or `?lang=it`) and has a 🎓 tutorial on the first puzzle
(`?tutorial`). The tutorial follows a logical path, not the answer key: put the first letter of every word, then
follow each word letter by letter while the sudoku forces where the next letter goes, and finish with plain sudoku.
It asks for the next step after every drop, so it copes with any order and points out wrong tiles.

The page is a [nimib](https://github.com/pietroppeter/nimib) notebook written in Nim and compiled to JavaScript.
Puzzles are crafted with [puzzlepaw](https://github.com/pietroppeter/puzzlepaw).

## Files

- `index.html`: the generated page (served by GitHub Pages from `main`, root). Don't edit it by hand.
- `src/parloku.nim`: the notebook. Model, rules, solver and drag spec run natively at build time and in the browser.
- `src/style.nim`: the page CSS (a maiolica theme), inlined in place of nimib's default theme.
- `data/`: puzzles as puzzlepaw JSON (`puzzleN-WORD1-WORD2-WORD3.json`), with their answer keys.
  At build time the solver checks each puzzle has a unique solution that matches its key.
- `src/deps.sh`, `src/config.nims`: fetch nimib and its dependencies at pinned commits into `src/deps/`.

## Build

Needs Nim 2.x (built with 2.2.4) and libpcre (PCRE1). From the repo root:

```sh
sh src/deps.sh
nim c -r -d:release src/parloku.nim   # writes index.html
```

## Links to a puzzle

Any puzzle can be played from a link: `?p=LETTERS_GIVENS_WORDS`, the same code format as puzzlepaw.
Givens are `<row><col><letter>` and words `<row><col><word>`, 0-based and separated by dots. For example
[`?p=AILPST_01S.33L.54P_50ITALIA.30PASTA.10ALPI`](https://pietroppeter.github.io/parloku/?p=AILPST_01S.33L.54P_50ITALIA.30PASTA.10ALPI).
