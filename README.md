# parloku

**Play it:** https://pietroppeter.github.io/parloku/

After you have played a few handcrafted puzzles, challenge yourself to create your own: you can become a puzzlecrafter and share your creations with friends!

**Build it:** https://pietroppeter.github.io/parloku/builder.html

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

Its look is a CSS *skin*: ten pastel ones after artists and illustrators (Munari, Tullet, Lionni, Miró, Taro Gomi,
Japanese wagashi, Delaunay, Bruna, Matisse, Maija Isola) plus the original maiolica, switchable at the top of the page
or with `?skin=tullet`. The Nim view only names classes, so a skin can change palette, fonts and tile shape.

The page is a [nimib](https://github.com/pietroppeter/nimib) notebook written in Nim and compiled to JavaScript.
Puzzles are crafted with [puzzlepaw](https://github.com/pietroppeter/puzzlepaw).

Devlog:
- [Built in CI](devlog/ci/): why the pages are no longer committed, one program for every page, the caches, and how the CI grows.
- [A daily hello and a first lesson](devlog/splash/): the daily splash screen and the animated lesson for first-time players.
- [Back to basics](devlog/basics/): the game screen taken apart piece by piece, UI design from first principles, and the changes it led to.
- [Ten skins for a letter game](devlog/pastel-skins/): how the skins were chosen and checked.

## Files

- The HTML pages (`index.html`, `builder.html`, `devlog/*/index.html`, ...) are not committed: CI builds them on every
  push and pull request and deploys them to GitHub Pages from `main` (`.github/workflows/pages.yml`).
- `src/devlog_ci.nim` → `devlog/ci/index.html`: devlog post on building the pages in CI.
- `src/all.nim`: builds every page in one program (any `src/*.nim` that calls `nbInit`, the game first).
- `src/parloku.nim`: the notebook. Model, rules, solver and drag spec run natively at build time and in the browser.
- `src/istruzioni.nim` → `istruzioni.html`: how to play (rules, then gestures), linked from the game menu.
- `src/splash.nim`: the daily splash screen and the animated first lesson (game page only; `?splash=first`, `?learn`, `?nosplash`).
- `src/devlog_splash.nim` → `devlog/splash/index.html`: devlog post on the splash and the lesson.
- `src/style.nim`: the page CSS (ten skins plus the original maiolica), inlined in place of nimib's default theme.
- `src/devlog_pastel_skins.nim` → `devlog/pastel-skins/index.html`: devlog post on how the skins were picked, built and
  audited (contrast and colour distance computed at build time). Build `src/parloku.nim` first, the post embeds its game.
- `data/`: puzzles as puzzlepaw JSON (`puzzleN-WORD1-WORD2-WORD3.json`), with their answer keys.
  At build time the solver checks each puzzle has a unique solution that matches its key.
- `src/deps.sh`, `src/config.nims`, `config.nims`: fetch nimib and its dependencies at pinned commits into `src/deps/` and put them on the path (the root one is for the `nim js` compiles nimib runs from the repo root).

## Build

Needs Nim 2.x (built with 2.2.4) and libpcre (PCRE1). From the repo root:

```sh
sh src/deps.sh
nim c -r -d:release src/all.nim       # every page, in one program (about 20 s, 3 s once Nim's cache is warm)
nim c -r -d:release src/parloku.nim   # or one page: writes index.html (devlog posts embed it, so build it first)
```

The pages are written next to the sources (`index.html`, `devlog/<post>/index.html`, ...) and ignored by git.
CI does the same build, keeps Nim's C cache between runs, and publishes the site from `main`.

## Links to a puzzle

Any puzzle can be played from a link: `?p=LETTERS_GIVENS_WORDS`, the same code format as puzzlepaw.
Givens are `<row><col><letter>` and words `<row><col><word>`, 0-based and separated by dots. For example
[`?p=AILPST_51S.23L.04P_00ITALIA.20PASTA.40ALPI`](https://pietroppeter.github.io/parloku/?p=AILPST_51S.23L.04P_00ITALIA.20PASTA.40ALPI).

## Builder

`builder.html` ([src/builder.nim](src/builder.nim)) makes new puzzles with the game's board and gestures. Pick a
set of three words. Each word is listed with a ring: drag the ring onto a cell to start the word there with its first
letter. Hold the word's last letter to see where the next one can go, then drag there (or tap one) to add it. The head can also be walked along the cells in one drag: each free next cell adds the next letter, stepping back onto the letter before shrinks the word, and letting go on an empty cell without a step moves the head there (as in the game). A double
tap on a letter sends it back, together with the rest of its word after it; a double tap on the ring removes the word.
Every empty cell shows in pencil the letters some complete grid can still put there, and a cell with none turns red.
A double tap on an empty cell with a single pencil mark puts that letter there. Holding a letter below makes the six
letters wiggle so they can be reordered by dragging one onto another; a double tap on a letter ends it. Four round tools sit next to the
words: 📌 drag the pin onto a placed letter to fix it as a clue (hold a pinned letter to unpin it), ↺ restart,
💾 copy a link that reopens the builder in this exact state (`builder.html?s=...`), and 🔗 copy the link to play. Next to undo, a solver looks for up to 10 complete grids that keep every letter on the board and fit all three
words, trying every start for the words not placed yet: it shows 0 when the words no longer fit, the exact number
up to 9, or 10+. For now it only looks for solutions where no word overlaps another or itself. In the pencil marks, the letters of the three
words in one of them take their word's colour; 🎲 shows another. A panel counts the solutions of
the puzzle a player would get (word starts and pinned letters only), with a link to play it.
The builder page is kept to one screen so pieces can be dragged without scrolling; its explanations are in
`builder-howto.html` ([src/builder_howto.nim](src/builder_howto.nim)), linked from the ? button.
The solver is [puzzlepaw](https://github.com/pietroppeter/puzzlepaw)'s `parloku/solver`, fetched by `deps.sh`
and compiled to JavaScript. Build with `nim c -r -d:release src/builder.nim`.

