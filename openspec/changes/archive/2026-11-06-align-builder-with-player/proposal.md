## Why

The player got a new look in PR #13 (classic grid, thin outlines, rolling conflicts). The builder should look and
feel the same, and Pietro wants to see every solution of a draft, not just a count. Built in PR #14 (project thread
"Build Parloku puzzle builder"), waiting for Pietro's review.

## What Changes

- The builder reuses the player's board: classic grid, thin rounded outlines inside their cells, rolling conflicts,
  drop targets only on cells. An empty cell where no letter can go keeps a light red tint (a builder warning).
- A word is grabbed anywhere on its row at the top; a double tap on the row takes it off the board.
- Under the board, one numbered circle per solution (up to 100, in two scrolling rows), instead of the count; tapping
  one shows that solution in the pencil marks.
- A solution counts only if each word reads one way from its start (no second path spelling it).

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `builder`: building by playing, pencil marks, counting solutions.

## Impact

- `src/builder.nim`, `builder.html`, `builder-howto.html`.
- First principles touched: one signal, one meaning (the same board as the game); every action gets an answer (every
  solution visible).
