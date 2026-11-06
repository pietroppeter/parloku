# solver Specification

## Purpose
Counting solutions: the backtracking solver that checks puzzles at build time and powers 💡 (hidden
since #13), and its larger sibling `src/solver.nim` that the builder uses (moved from puzzlepaw in #19, checked
by `tests/test_solver.nim` in CI).

## Requirements

### Requirement: Build-time check
Building the game SHALL solve every puzzle in `data/`, report whether it has one solution, and say whether that
solution matches the stored answer key.

#### Scenario: The shipped puzzles
- **WHEN** the game is built
- **THEN** each puzzle prints "1 solution (unique), matches the answer key in data/" and the path of each word

### Requirement: Stop early
The solver SHALL stop after a given number of solutions (2 in the game, enough to tell unique from not; 100 in the
builder, shown as numbered circles), and it SHALL prune with the word clues, where an empty cell can stand for any letter.

#### Scenario: Two solutions found
- **WHEN** a setup has many solutions
- **THEN** the game's solver returns after the second one

### Requirement: One rule for words
The game's solver, the builder's solver and the outlines on the board SHALL agree on how a word may run through the
grid (see the `settle-word-overlaps` change: today they don't).

#### Scenario: A word that comes back on itself
- **WHEN** a setup only works if a word steps back onto one of its own cells
- **THEN** every part of Parloku gives the same answer about it
