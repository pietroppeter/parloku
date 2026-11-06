## Why

Pietro, 6 November 2026 (project thread "Celebrate solving a puzzle", ahead of the 0.2 playtest release): the
"Bravo!" at the end is masculine only, so a girl who solves a puzzle is told she is a boy. And the end could be a lot
more festive: the letters on the board could do something.

## What Changes

- The banner says **Evviva! 🥳** (gender neutral) instead of Bravo!. The other masculine words the player reads go too:
  the tutorial's "Benvenuto!" and "da solo", and the splash's "Gioco da solo".
- When the last tile solves the grid, the letters on the board dance for about three seconds before the banner pops
  up. Three dances, one picked at random on every win (Pietro): ripples spreading from the last letter placed, like a stone in a pond; the snakes, each word hopping letter by letter; the letters, all copies of a letter jumping and spinning together. The firework was previewed and left out for now.
- The banner sits over the empty letter trays at the bottom, so the solved board stays in view.
- A board that was already solved (a reload) shows the banner at once, with no dance and no confetti.
- With reduced motion, the letters stay still.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `player`: winning.
- `first-principles`: the loop's last step is the party, not Bravo!.

## First principles touched
- Write the loop: "after" is now the party and Evviva!.

## Impact
- `src/parloku.nim`: `celebrate` (the dance), the banner text; tutorial texts.
- `src/splashrt.nim`: the "play on my own" button.
- `src/style.nim`: the banner's place and when it shows (`.won.cheer`).
