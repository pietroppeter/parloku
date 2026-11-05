## Why

Playtesting puzzle 2 (AMICA GIOCO MAGIA) found two more snake gestures that don't work:
dragging a head on past the first new letter moves the head instead of growing the word further, and there is no
way to take back a wrong turn except one letter at a time. Both should work in a single drag, without lifting the
finger. Being fixed in PR #8, together with the head moves that already landed there.

## What Changes

- A drag from a word's head SHALL keep growing the word for as long as the finger moves on to empty cells next to the
  new head, one letter per cell.
- Dragging a head back onto the cell before it SHALL shrink the word, one letter per cell, sending the letters
  back to their stacks. Shrinking and growing combine in one drag, so a wrong turn is fixed in one gesture.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `word-snakes`: growing from the head goes on for several letters; new requirement for shrinking.

## Impact

- `src/parloku.nim`: `tileSpec` and the stage (the held tile must be re-specified when it becomes a new head
  mid-drag), and the builder, which uses the same gesture (PR #6).
- The scenarios below run with `nim r tools/specdrag.nim`; they show as "todo" until the code passes them.
