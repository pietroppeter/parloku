## Why

Pietro, 6 November 2026, after playing on his phone: he needs undo and redo while he plays. He drew two round buttons
in the empty space at the top right, under the menu bar. Until now ↶ undo was hidden on purpose, and the only way back
from a mistake was a double tap or rifaccio's undo window.

## What Changes

- Two round buttons, ↶ undo and ↷ redo, come down with the menu and go back up with it. They sit at the top right, next
  to the first word, apart from the three menu buttons.
- ↶ takes back the last move, one at a time, back to the puzzle's start. ↷ does a taken-back move again. A new move
  forgets the moves that were taken back. A button with nothing to do is shown faded.
- Tapping them keeps the menu down for another 4 seconds, so several moves can be taken back in a row.
- 💡 hint and 🔗 link stay hidden. Rifaccio and its undo window stay as they are.
- Undo covers everything the player changes on the board, including notes once they land (PR #23), because it keeps
  whole boards.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `player`: undo and redo in the menu.

## First principles touched
- Any single move is easy to take back: now also with ↶, and a step taken back can be redone.

## Impact
- `src/parloku.nim` (the `history` and `future` of boards, the two buttons), `src/style.nim` (`.undos`),
  `tests/gestures/undo.js`. Built in the undo/redo PR.
