## Why

Making a puzzle today means puzzlepaw's terminal UI and a JSON file. Pietro wants to build puzzles by playing:
place the words on the board, see at once how many grids still fit, pin givens until there is one. This is PR #6
(the "Build Parloku puzzle builder" thread), not merged yet.

## What Changes

- A new page, `builder.html` (`src/builder.nim`), compact enough to use without scrolling, and `builder-howto.html`
  with the explanations (in Italian for now).
- The builder uses the game's board, tiles and gestures, plus pencil marks and a live solution count from
  puzzlepaw's `parloku/solver`.

## Capabilities

### New Capabilities
- `builder`: the puzzle builder page.

### Modified Capabilities
- none

## Impact

- New dependency: puzzlepaw (`src/deps.sh`), for `parloku/types` and `parloku/solver`.
- The word rule the builder's solver uses (no word on its own cells, no two words on one cell, optional no U-turns)
  differs from the game's: see `settle-word-overlaps`.
