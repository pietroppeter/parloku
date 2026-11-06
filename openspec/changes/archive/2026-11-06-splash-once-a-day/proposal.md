## Why

The spec says the daily splash greets a day's first visit, but the game opened it on every load: each link to the
game, and each reload, showed it again (Pietro, 6 November 2026, opening game links inside Claude).

## What Changes

- The splash remembers the day it was shown (`parloku:splashday` in localStorage) and stays closed for the rest of
  that day. The first-visit splash still shows until the player closes it; `?splash=first`, `?day=` and `?learn`
  still open it.
- `tests/gestures/splash.js` checks a second visit on the same day and a visit the next day.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `player`: a scenario for coming back the same day.

## Impact

- `src/splashrt.nim`, `tests/gestures/splash.js`.
