## Why

PR #20 (game thread, 6 November 2026) changes how Parloku teaches itself, after Pietro's notes. The first lesson
spoiled puzzle 1 and asked a quiz about mini sudoku, and the istruzioni page only described the gestures. The
devlog had no index page.

## What Changes

- The first lesson has its own small example, NERO / ROSA / ORO, so it gives away no puzzle. It has the game's look,
  and it no longer asks whether the player knows the mini sudoku. No word in it makes a U, and its finger shows
  every gesture, the two sure cells each on its own (Pietro, 6 November).
- Under every gesture on the istruzioni page there is a practice board, with that gesture's position set up and a
  "↺ da capo" button. Clashes have one as well. The boards are the game itself in a `?demo` mode: started from
  `&g=`, with no menu, and saving nothing.
- `devlog/` gets an index page that lists every post, newest first, built from the posts' sources.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `how-to-play`: the first lesson and the istruzioni page.
- `way-of-working`: the devlog index.

## First principles touched
- Every action gets an answer: a gesture is learnt by doing it, next to its description.

## Impact
- `src/splash.nim`, `src/splashrt.nim`, `src/istruzioni.nim`, `src/parloku.nim` (`?demo`), `src/devlog_index.nim`.
