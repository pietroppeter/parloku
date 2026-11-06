## Why

Pietro, 6 November 2026, getting 0.2 ready for playtesting: with ten puzzles, the "ancora!" list no longer fits the
menu bar. The puzzles were squeezed side by side at the top and their names were cut off, so the list was broken. He
asked for a list that rises from below, in order, numbered, with a check box on the puzzles already solved. "When there
are more puzzles we will invent something better, but for now that's fine."

## What Changes

- Tapping ancora! sends the menu bar up. The words then run off the screen one at a time, to the left and to the right
  in turn, and the grid follows with the letters below it. Then the list of puzzles rises from the bottom, one row at a
  time.
- Each row has the puzzle's number (1 to 10), its three words, and a check box at the right. The box is ticked once the
  puzzle is solved on this device. The puzzle in play is highlighted.
- Tapping a puzzle folds the list down and brings the new puzzle's words and grid in from the sides, starting afresh as
  before. Tapping the puzzle in play, or the empty space beside the rows, folds the list down and brings the same puzzle
  back.
- The puzzles no longer appear in the menu bar. The bar keeps istruzioni, ancora! and rifaccio.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `player`: choosing and changing puzzle through a list that rises from below.

## First principles touched
- One thing on the screen at a time: while you choose, only the list is shown.

## Impact
- `src/parloku.nim` (`#games` panel, `openList`/`closeList`; the old sideways list and the left-to-right switch are
  gone), `src/style.nim` (`.games`), `tests/gestures/menu.js` and `switch.js`.
