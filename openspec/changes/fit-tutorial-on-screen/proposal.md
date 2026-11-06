## Why

The 🎓 tutorial works, but its coach box sits above the clues and pushes the six letters to 806 px on an iPhone 13,
past the one-screen rule in `first-principles` (664 px). Since #13 it also has no button: only `?tutorial` and the
first lesson open it. Pietro, 6 November 2026: the tutorial must fit the screen, with its messages on white-ish,
semi-transparent blobs over the board that never hide what the player needs for the step.

## What Changes

- The coach's messages become semi-transparent white-ish blobs laid over the play area, not a box above it, so the
  clues, the board and the six letters stay where they are in the game.
- A blob SHALL NOT cover what the current step needs: the cells it names, the target cell, the letter to pull, and
  the clue it is about. It moves to a free part of the screen for each step.
- The istruzioni page gets a link to the tutorial, so it can be found without knowing `?tutorial`.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `how-to-play`: the tutorial fits the screen, its messages float over the game, and istruzioni links to it.

## First principles touched
- The whole loop on one screen.
- Things that work together sit together: the explanation sits by the cells it talks about.

## Impact
- `src/parloku.nim` (the coach) and `src/style.nim` (the blob look), `src/istruzioni.nim` (the link).
