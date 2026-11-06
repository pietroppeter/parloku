## MODIFIED Requirements

### Requirement: One rule for words
The game's solver, the builder's solver and the outlines on the board SHALL agree on how a word may run through the
grid: never twice over the same cell, and never over a cell of another word.

#### Scenario: A word that comes back on itself
- **WHEN** a setup only works if a word steps back onto one of its own cells
- **THEN** every part of Parloku gives the same answer about it: not a solution

#### Scenario: Two words on one cell
- **WHEN** a setup only works if two words share a cell
- **THEN** every part of Parloku gives the same answer about it: not a solution
