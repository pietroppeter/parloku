## Why

Writing the specs showed three parts of Parloku disagreeing on one rule: may a word pass twice over the same cell?

- The board's outlines never use a cell twice (since PR #8: G-I-O-C no longer reads as GIOCO).
- The game's solver (`trace(..., revisit = true)`) lets a word step back onto its own cells.
- The builder's solver (PR #6) forbids it, also forbids two words on one cell "for now", and has an optional
  "no U-turn" filter.

A puzzle could then be unique for the builder and ambiguous for the game, or be solved in the game while its outline
never completes. This is a rule of the puzzle, so it is Pietro's call.

## What Changes

- **Decision needed:** (a) a word never uses the same cell twice, (b) whether two different words may share a
  cell, (c) whether U-turns are allowed.
- Once decided: one `trace` rule in the game, the builder and puzzlepaw's solver, and the rule in `game-rules`.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `game-rules`: words are spelled one step at a time, now saying whether cells may be reused.
- `solver`: one rule for words everywhere.

## Impact

- `src/parloku.nim` (`trace`, `solved`, `solve`), puzzlepaw `parloku/solver`, the builder.
- Every shipped puzzle is re-checked for uniqueness under the new rule.
