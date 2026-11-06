## Why

Pietro, 6 November 2026, playing ESTATE · MARE · SERATA: he dragged SERATA's last A from r5c5 up to an empty cell at
the top right, to move it, and the A went back below instead. On its way the finger crossed the T before the A, and
crossing the cell before the head took the head off the board at once.

## What Changes

- Going back onto the cell before the head no longer takes the head off right away. It is taken off when the player
  lets go there, keeps going backwards, or turns from there onto a free cell next to it (the wrong-turn fix).
- If the finger goes on from the cell before to any other cell, nothing is taken off, and letting go on an empty cell
  away from the head moves the head there, as the "Moving a head" requirement already says.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `word-snakes`: "Moving a head" and "Shrinking a word".

## First principles touched
- A gesture does what the player means: a move stays a move even when the finger crosses a letter on its way.

## Impact
- `src/parloku.nim` (the snake drag: a pending back step), the scenario "Past the letter before, to a far cell",
  `tests/gestures/head.js` (Pietro's SERATA board).
