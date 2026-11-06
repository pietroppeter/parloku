## Why

Pietro, 6 November 2026: for now the game's language is Italian, and English is a draft. There is no language switch
in the menu. English stays the language of development and iteration: specs, code, commits and PRs (Pietro often
writes in Italian, or mixes the two).

Today the game picks the browser's language, so most players outside Italy get the English draft.

## What Changes

- The game opens in Italian unless a link asks for English (`?lang=en`) or English was chosen before.
- English is a draft. It should follow, but it may lag behind Italian, and a missing English text is not a bug.
- No language switch in the menu.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `languages`: Italian first, English as a draft.

## First principles touched
- One job per piece: no switch on the play screen for something most players never change.

## Impact
- `src/parloku.nim`: the default language stops following the browser.
- `src/splash.nim`: the same default.
