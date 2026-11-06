## Why

Pietro reviewed the player's menu (5 November 2026): there are too many buttons at the top, and a reset can't be
taken back. Built in PR #13 (project thread "Evolve Parloku game and devlog"), merged on 6 November 2026, together with a new
look for the board.

## What Changes

- The top of the game has only three buttons: **istruzioni** (a new page, `istruzioni.html`, with the rules of the
  game and then the gameplay; no solving tutorial for now), **ancora!** (a list to pick another puzzle, with the solved
  ones ticked) and **rifaccio** (reset).
- Reset restarts right away, with no "sure?". For 8 seconds afterwards, or until the first move if that comes sooner,
  the button reads **annullo rifaccio** and brings back the board, its history and the clock. On an untouched board
  there is nothing to undo, so it isn't offered.
- Solved puzzles are remembered in the browser (`parloku:solved`).
- The menu slides down on a tap above the grid and goes back up after 4 seconds or on a tap in the game. ancora! shows
  the puzzles sideways in place of the buttons; changing puzzle sends words, grid and letters out to the left one at a
  time and brings the new ones in from the right. rifaccio only shows once a letter is down.
- The board: the classic mini sudoku grid (thin and thick lines; `?grid=rounded` keeps the old one for now), word
  outlines as thin rounded squares inside their cells, and letters in conflict that roll like marbles instead of red
  cells.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `player`: the menu, reset and its undo, solved puzzles.
- `first-principles`: "mistakes are cheap" is met by undoing a reset, not by asking first.
- `play-screen`: the board's grid, outlines and conflicts.
- `theming`: what signals a broken rule.
- `how-to-play`: the istruzioni page.
- `word-snakes`: the outline's shape.

## Impact

- `src/parloku.nim` (menu and reset), a new `src/istruzioni.nim` page.
- First principles touched: one job per piece (fewer buttons), mistakes are cheap (undoing a reset).
