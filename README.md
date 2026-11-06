# parloku

**Play it:** https://pietroppeter.github.io/parloku/

After you have played a few handcrafted puzzles, challenge yourself to create your own: you can become a puzzlecrafter and share your creations with friends!

**Build it:** https://pietroppeter.github.io/parloku/builder.html

**Specs:** https://pietroppeter.github.io/parloku/specs/ (how Parloku behaves today, kept current by CI)

Parloku is a mini sudoku spelled in letters (a *wordoku*) with words hidden in it.
Fill the 6×6 grid so each of six letters appears once per row, column and 2×3 box, and
so every clue word can be spelled from its marked cell, one step at a time up, down, left or right.

Here you play by dragging: below the board each letter is one coloured tile, and pulling it
divides it, so the copy goes up into a cell. The dragging is a small port of
[Declarative Dragging](https://declarative-dragging.github.io/) (Horowitz, Blinn & Heer, UIST 2026):
the code never handles a drop, it only lists the boards a drag can reach.

The game speaks English and Italian (EN / IT switch, or `?lang=it`) and has a 🎓 tutorial on the first puzzle
(`?tutorial`). The tutorial follows a logical path, not the answer key: put the first letter of every word, then
follow each word letter by letter while the sudoku forces where the next letter goes, and finish with plain sudoku.
It asks for the next step after every drop, so it copes with any order and points out wrong tiles.

Its look is a CSS *skin*. The game uses one, after Niki de Saint Phalle; the others (Munari, Tullet, Lionni, Miró and more)
stay reachable by link for trying out, such as `?skin=tullet`. The Nim view only names classes, so a skin can change
palette, fonts and tile shape.

The game is in Italian. English is a draft, reachable only with `?lang=en`.

The game is a [nimib](https://github.com/pietroppeter/nimib) notebook written in Nim and compiled to JavaScript.
The notebook itself, prose and code, is the devlog post [How it works](https://pietroppeter.github.io/parloku/devlog/how-it-works/); the game page keeps only the game.
Puzzles are crafted with [puzzlepaw](https://github.com/pietroppeter/puzzlepaw).

Specs: [how Parloku behaves](https://pietroppeter.github.io/parloku/specs/), written down with [OpenSpec](https://github.com/Fission-AI/OpenSpec) in
`openspec/`. The gameplay scenarios are played on the built game and shown as small animations.

Devlog ([index](https://pietroppeter.github.io/parloku/devlog/)). It lists the living documents first, then the dated posts.

Living documents, kept up to date as the game changes (a new one gets a row in `src/devlog_index.nim`):
- [Specs](https://pietroppeter.github.io/parloku/specs/): how Parloku behaves today, rebuilt from `openspec/` on every push.
- [How it works](https://pietroppeter.github.io/parloku/devlog/how-it-works/): the game's own notebook. The model, the rules as code, a logical solver, the drag spec and the browser runtime.
- [Istruzioni](https://pietroppeter.github.io/parloku/istruzioni.html): how to play, with a practice board for each gesture.
- [Builder](https://pietroppeter.github.io/parloku/builder.html) and its [how-to](https://pietroppeter.github.io/parloku/builder-howto.html).

Posts, dated and not updated afterwards (the index reads them from their sources, newest first):
- [Tiles that divide like cells](https://pietroppeter.github.io/parloku/devlog/cells/): an experiment, a round tile that buds a copy and coalesces back, and how the animation is drawn.
- [Built in CI](https://pietroppeter.github.io/parloku/devlog/ci/): why the pages are no longer committed, one program for every page, the caches, and how the CI grows.
- [Specs that play](https://pietroppeter.github.io/parloku/devlog/openspec/): adopting OpenSpec, and drag scenarios that are animations and tests at once.
- [A daily hello and a first lesson](https://pietroppeter.github.io/parloku/devlog/splash/): the daily splash screen and the animated lesson for first-time players.
- [Back to basics](https://pietroppeter.github.io/parloku/devlog/basics/): the game screen taken apart piece by piece, UI design from first principles, and the changes it led to.
- [Ten skins for a letter game](https://pietroppeter.github.io/parloku/devlog/pastel-skins/): how the skins were chosen and checked.

## Files

- The HTML pages (`index.html`, `builder.html`, `devlog/*/index.html`, ...) are not committed: CI builds them on every
  push and pull request and deploys them to GitHub Pages from `main` (`.github/workflows/pages.yml`).
- `src/devlog_ci.nim` → `devlog/ci/index.html`: devlog post on building the pages in CI.
- `src/devlog_cells.nim` → `devlog/cells/index.html`: devlog post on the cell-division drag experiment (dragging with [zogyn](https://github.com/pietroppeter/zogyn), pinned in `deps.sh`).
- `src/all.nim`: builds every page in one program (any `src/*.nim` that calls `nbInit`, the game first).
- `src/parloku.nim`: the notebook. Model, rules, solver and drag spec run natively at build time and in the browser.
  It writes two pages: `devlog/how-it-works/index.html` (the whole notebook) and `index.html` (only the game).
- `src/istruzioni.nim` → `istruzioni.html`: how to play (rules, then gestures), linked from the game menu. Each gesture has a practice
  board: the game in `?demo` mode in a frame (starts from the letters in `&g=`, saves nothing, no menu).
- `src/splash.nim`: the daily splash screen and the animated first lesson, markup and style (game page only; `?splash=first`, `?learn`, `?nosplash`, `?day=`).
- `src/splashrt.nim`: the splash's behaviour, in Nim, compiled into the game's script.
- `src/devlog_index.nim` → `devlog/index.html`: the living documents (a table in the source), then every devlog post, newest first, read from the posts' sources.
- `src/devlog_splash.nim` → `devlog/splash/index.html`: devlog post on the splash and the lesson.
- `src/style.nim`: the page CSS (ten skins plus the original maiolica), inlined in place of nimib's default theme.
- `src/devlog_pastel_skins.nim` → `devlog/pastel-skins/index.html`: devlog post on how the skins were picked, built and
  audited (contrast and colour distance computed at build time). Build `src/parloku.nim` first, the post embeds its game.
- `openspec/`: the specs (`specs/`) and the open changes (`changes/`); `openspec/config.yaml` has the project's rules.
  `AGENTS.md` has the working rules.
- `tools/specdrag.nim`: collects the ```` ```drag ```` scenarios of the specs and `tools/specdrag.js` plays
  them on the built `index.html` in headless Chromium (`nim r tools/specdrag.nim`, needs Node and Playwright); `tools/specview.nim` draws specs and changes for the pages below.
- `src/specs_page.nim` → `specs/index.html`: the living spec page. `src/devlog_openspec.nim` →
  `devlog/openspec/index.html`: the dated post on adopting OpenSpec (it does not follow later spec changes).
- `src/solver.nim`: the solver the builder uses (counts and lists complete grids, exact pencil marks), moved from puzzlepaw; `tests/test_solver.nim` checks it.
- `data/`: puzzles as puzzlepaw JSON (`puzzleN-WORD1-WORD2-WORD3.json`), with their answer keys.
  At build time the solver checks each puzzle has a unique solution that matches its key.
- `src/deps.sh`, `src/config.nims`, `config.nims`: fetch nimib and its dependencies at pinned commits into `src/deps/` and put them on the path (the root one is for the `nim js` compiles nimib runs from the repo root).

## Build

Needs Nim 2.x (built with 2.2.4) and libpcre (PCRE1). From the repo root:

```sh
sh src/deps.sh
nim c -r -d:release src/all.nim       # every page, in one program (about 20 s, 3 s once Nim's cache is warm)
nim c -r -d:release src/parloku.nim   # or one page: writes index.html (devlog posts embed it, so build it first)
nim r tools/specdrag.nim              # runs the drag scenarios in openspec/ (needs Node and Playwright)
```

The pages are written next to the sources (`index.html`, `devlog/<post>/index.html`, ...) and ignored by git.
CI does the same build, keeps Nim's C cache between runs, and publishes the site from `main`.

## Links to a puzzle

Any puzzle can be played from a link: `?p=LETTERS_GIVENS_WORDS`, the same code format as puzzlepaw.
Givens are `<row><col><letter>` and words `<row><col><word>`, 0-based and separated by dots. For example
[`?p=AILPST_51S.23L.04P_00ITALIA.20PASTA.40ALPI`](https://pietroppeter.github.io/parloku/?p=AILPST_51S.23L.04P_00ITALIA.20PASTA.40ALPI).

## Builder

`builder.html` ([src/builder.nim](src/builder.nim)) makes new puzzles with the game's board and gestures. Pick a
set of three words. The sets come from [`data/terne.txt`](data/terne.txt), one per line; a set that already has a puzzle in `data/` is left out of the list, so the builder only offers triples still to be made. Each word is listed with a ring: drag the ring onto a cell to start the word there with its first
letter. Hold the word's last letter to see where the next one can go, then drag there (or tap one) to add it. The head can also be walked along the cells in one drag: each free next cell adds the next letter, stepping back onto the letter before shrinks the word, and letting go on an empty cell without a step moves the head there (as in the game). A double
tap on a letter sends it back, together with the rest of its word after it; a double tap on the ring removes the word.
Every empty cell shows in pencil the letters some complete grid can still put there, and a cell with none turns red.
A double tap on an empty cell with a single pencil mark puts that letter there. Holding a letter below makes the six
letters wiggle so they can be reordered by dragging one onto another; a double tap on a letter ends it. Four round tools sit next to the
words: 📌 drag the pin onto a placed letter to fix it as a clue (hold a pinned letter to unpin it), ↺ restart,
💾 copy the puzzle as JSON, with its solution and a link that reopens the builder in this exact state (`builder.html?s=...`), and 🔗 copy the link to play. Under the board, one numbered circle per solution (up to 100, in two rows that scroll sideways): complete grids
that keep every letter on the board and fit all three words, trying every start for the words not placed yet. For now
a word never overlaps another or itself, never turns back in a U, and must read one way only from its start. Tapping a
circle shows that solution in the pencil marks: the letters of the three words in their word's colour, the rest in black.
The builder page is kept to one screen so pieces can be dragged without scrolling; its explanations are in
`builder-howto.html` ([src/builder_howto.nim](src/builder_howto.nim)), linked from the ? button.
The solver is [src/solver.nim](src/solver.nim), moved here from [puzzlepaw](https://github.com/pietroppeter/puzzlepaw)
with only what the builder needs, and compiled to JavaScript ([tests/test_solver.nim](tests/test_solver.nim) checks it on
the puzzles in `data/`). Build with `nim c -r -d:release src/builder.nim`.

