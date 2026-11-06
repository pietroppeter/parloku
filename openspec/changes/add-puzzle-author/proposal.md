## Why

Pietro, 6 November 2026 (project thread "Add new puzzles to Parloku", PR #24): puzzles now come from more than one
hand. Pietro makes them in the builder, and Claude proposes some for him to playtest (ESTATE · MARE · SERATA is the
first one he kept). Each puzzle file should say who made it and when.

## What Changes

- Every puzzle file in `data/` gets two top-level fields next to `problem` and `solution`: `author` (a GitHub login,
  or `claude`) and `created` (the day it was made, `YYYY-MM-DD`).
- Puzzles 1 and 2 are Pietro's, created on 2026-02-22 (the day they were saved in puzzlepaw, commit 9d12d50).
  Puzzle 3 (PAROLE · PERLE · OPERA) is Pietro's, from the builder, 2026-11-06. Puzzle 4 (ESTATE · MARE · SERATA) is
  Claude's, 2026-11-06.
- The solver test checks that every puzzle has both fields.
- The game does not show them yet.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `puzzle-format`: puzzle files carry an author and a creation date.

## First principles touched
- none (no screen changes)

## Impact
- `data/puzzle*.json`, `tests/test_solver.nim`, README.
- The builder's 💾 JSON does not have the fields yet: they are added when a puzzle is saved to `data/`.
