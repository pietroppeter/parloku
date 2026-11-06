## Why

Pietro, 6 November 2026 (project thread "Distinguish snake head from tail"): a word's outline looks the same at both
ends, so on the board you can't tell where a word starts and where it has got to. He looked at three ideas drawn by
the game (a tinted start with a thicker head, eyes on the head, an outline that thickens towards the head) and chose
the tinted start together with the eyes.

## What Changes

- A word's start cell holds a soft tint of the word's colour, under the letter, whether the word has letters or not.
- Once a word has two letters or more, its head (the last letter its outline covers) has two small eyes on its front
  edge, on the outline, looking the way the last step went.
- The outline itself is unchanged: thin, rounded, the same thickness everywhere.
- The help text (the game's "02 · PAROLE" and the istruzioni page) says so.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `word-snakes`: the outline of a word shows its start and its head.

## First principles touched
- One signal, one meaning: the tint means "a word starts here" and the eyes mean "the word has got here"; neither is
  only a colour (the eyes are a shape, the tint is in a fixed place, the start cell).

## Impact
- `src/parloku.nim` (`backdrop` draws the start tint, `overlay` the eyes), `src/style.nim` (`.wbase`, `.eye`),
  `src/istruzioni.nim` (help text). The explainer page (`src/stepsview.nim`, not on main yet) copies the game's outline
  and will mirror it.
