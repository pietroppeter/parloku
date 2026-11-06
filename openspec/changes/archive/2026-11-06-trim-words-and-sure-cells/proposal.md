## Why

Pietro, 6 November 2026 (relayed from the game thread, PR #20), changed two rules about the double tap:

- A double tap on a letter inside a word should take back that letter and the ones after it, not the whole word. The
  builder already works this way.
- Sure cells, the empty cells a double tap fills, are only a word's start cell and the last free cell of a row, column
  or box. Since the solution is unique, every cell has one right letter in theory, so "sure" has to mean one of these
  cases, which a player can check by eye.

## What Changes

- A double tap on a word's letter sends that letter and every later letter of the word back below. The letters before
  it stay, and givens always stay. A double tap on a word's first letter therefore clears the whole word.
- A double tap on an empty cell fills it only if it is a word's empty start cell, or the last free cell of a row,
  column or box whose other five letters are all different. On any other empty cell it does nothing.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `tiles-and-dragging`: the double taps.
- `word-snakes`: sending a word back from a letter on.

## First principles touched
- Mistakes are cheap: a wrong turn deep in a word costs only the letters after it.
- One signal, one meaning: "sure" means a case the player can see, not a guess the game makes.

## Impact
- `src/parloku.nim`: the double tap on a word letter (PR #20 does it), and `sureLetter`.
