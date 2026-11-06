## Why

Pietro, 6 November 2026, in the 0.2 release thread: new players don't find the menu. It opens with a tap on the empty
space above the grid, and the only place that says so is istruzioni, which is in the menu. He asked for a way to tell
them without reading instructions, perhaps a small message delivered by a little snake. Three options were previewed
(a note with an arrow, a snake, the menu peeking out by itself) and Pietro picked the snake.

## What Changes

- A little snake of four tiles spelling MENU, with the eyes the word heads have, comes into the empty space at the top
  a few seconds after the game is on screen, and a speech bubble says "psst! tocca qui: c'è il menu". It waves while it
  moves, rests while it talks, and goes away by itself after about 11 seconds. It never takes a tap: taps pass through
  it to the game.
- Where there is room above the words (taller screens) it crawls in from the left, with the bubble beside it. On short
  screens (an iPhone 13 has no room above the words) it pops up in the free corner right of the first word, with the
  bubble right of the second word.
- It comes once on each visit, and once more after a win ("psst! tocca qui per un altro puzzle"), because ancora! is in
  the menu, until the player has opened the menu once. Then it never comes again on that device (`parloku:menu`).
- It waits for the splash or the first lesson to close. It does not come in the tutorial, on the istruzioni practice
  boards (`?demo`) or in the devlog posts.
- When the menu comes down, the snake goes away at once.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `player`: a snake shows a new player where the menu is.

## First principles touched
- Nothing to read before playing: the gesture for the menu is shown in the game, not only in istruzioni.
- The screen keeps only the game: the snake is passing, never a button, and goes for good once it has done its job.

## Impact
- `src/parloku.nim` (`snakeCome`, `snakeLeave`, `snakeFoundMenu`), `src/style.nim` (`.hint-snake`),
  `tests/gestures/menuhint.js`, `tools/specdrag.js` (scenario runs start with the menu already found, so the snake
  stays out of the recorded frames). Built in the menu hint PR.
