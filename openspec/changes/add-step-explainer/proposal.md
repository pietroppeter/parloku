## Why

Pietro, 6 November 2026 (project thread "Add new puzzles to Parloku", PR #24): puzzles have to be solvable with
logical steps, not only have one solution. To see whether a puzzle is, and how, we need its solution explained move by
move. He liked the first automatic explanation (PAROLE · PERLE · OPERA) and asked for a page that explains any puzzle
live, plus a devlog post that tells it.

## What Changes

- A step solver (`src/stepsolver.nim`) solves with moves a person can check, in this order: follow the word, only
  place in a row/column/box, only letter, eliminations. It never guesses, and says where it gets stuck.
- A gallery (`src/stepsview.nim`) draws each move: the board, the reason shaded, each word's container as in the game,
  the words above with round letters, and the pencil marks. Swipe, or tap to go on (tap the left side to go back).
- A new page `spiega.html?p=<code>` explains any puzzle in the browser; without a code it lists the puzzles in `data/`.
- A devlog post, "A puzzle, step by step" (`devlog/steps/`), with frozen runs.

## Capabilities

### New Capabilities
- `explainer`: the spiega page and its gallery.

### Modified Capabilities
- none (the tutorial's `logical-path` stays as it is)

## First principles touched
- none on the play screen; the spiega page is a new page.

## Impact
- New: `src/stepsolver.nim`, `src/stepsview.nim`, `src/spiega.nim`, `src/devlog_steps.nim`, `src/devlog_steps/`.
- README: the new page and the devlog line.
