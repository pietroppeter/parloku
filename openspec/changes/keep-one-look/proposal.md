## Why

Pietro chose (6 November 2026) that the game has one look: the Niki skin on the classic grid. There is no skin
switcher on the page, and the rounded grid goes away. The other
skins stay in the code for testing and for the styles devlog (PR #5, `devlog/styles`, 30 candidate styles), but a
player never has to pick one.

## What Changes

- The switch below the game goes away.
- Niki is the only skin a player sees.
- The ten pastel skins stay reachable with `?skin=<name>`, for testing only. The original maiolica skin is retired.
- The rounded grid and `?grid=rounded` go away; the board is only the classic mini sudoku grid.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `theming`: choosing a skin. The page offers no choice, and other skins are only reachable through `?skin=` for testing.
- `play-screen`: the board is only the classic grid.

## First principles touched
- One clear look for the player; the other styles are kept as experiments (styles devlog).

## Impact
- `src/parloku.nim`: remove the skin switcher and the rounded grid (the game's thread is doing it).
- `src/style.nim`: unchanged. Every skin stays.
