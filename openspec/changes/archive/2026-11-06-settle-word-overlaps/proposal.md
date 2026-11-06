## Why

Writing the specs showed three parts of Parloku disagreeing on one rule: may a word pass twice over the same cell?

- The board's outlines never use a cell twice (since PR #8: G-I-O-C no longer reads as GIOCO).
- The game's solver (`trace(..., revisit = true)`) lets a word step back onto its own cells.
- The builder's solver (PR #6) forbids it, also forbids two words on one cell "for now", and has an optional
  "no U-turn" filter.

A puzzle could then be unique for the builder and ambiguous for the game, or be solved in the game while its outline
never completes. This is a rule of the puzzle, so it is Pietro's call.

## What Changes

- **Decided by Pietro (6 November 2026): a word never uses the same cell twice.** That is already true of the
  outlines and the builder; the game's solver (`solved`, `solve`) changes to match, and every shipped puzzle is
  re-checked for a unique solution under the rule.
- **Decided by Pietro (6 November 2026, after a playtest): two words never share a cell.** In the game, OPERA's outline
  ran over PERLE's P as soon as that P was put on PERLE's start cell next to OPERA's O. Now:
  - an outline never enters another word's start cell;
  - where two outlines could take the same letters, the longer one keeps them (on a tie, the word listed first) and the
    other goes around them;
  - stretching a word never steps onto another word's start cell;
  - the game's solver, the builder's and `src/solver.nim`'s `defaultOptions` (which allowed both reuse and sharing) all
    follow the two rules.
- Not decided, staying as it is today: U-turns (the builder's optional "niente U" filter; example grids avoid them).

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `game-rules`: words are spelled one step at a time, and never use a cell twice or share one.
- `word-snakes`: outlines never overlap.
- `solver`: one rule for words everywhere.

## Impact

- `src/parloku.nim` (`trace`, `outlines`, `solved`, `solve`, the snake), `src/builder.nim` (its copy of the same),
  `src/solver.nim` (`defaultOptions`). Built in PR #20.
- Every shipped puzzle is re-checked for uniqueness under the new rule.
