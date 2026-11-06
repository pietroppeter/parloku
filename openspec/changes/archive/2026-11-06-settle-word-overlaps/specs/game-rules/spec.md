## MODIFIED Requirements

### Requirement: Words are spelled one step at a time
Every word clue SHALL have a start cell, and a solved grid SHALL spell the word from that cell by moving at each
letter to the cell above, below, left or right of the previous one. Diagonal steps SHALL NOT count. A word SHALL NOT
use the same cell twice, and two words SHALL NOT share a cell.

#### Scenario: A word down a column
- **WHEN** AMICA starts at r1c1 and the grid has A M I in the first column and C A to the right of the I
- **THEN** AMICA is spelled

#### Scenario: A diagonal step
- **WHEN** the only M next to a word's A is diagonal to it
- **THEN** the word is not spelled from there

#### Scenario: Stepping back onto its own cell
- **WHEN** GIOCO has G I O C in a row and its last O could only be the O it already used
- **THEN** GIOCO is not spelled

#### Scenario: Two words on one cell
- **WHEN** a grid spells PASTA only if its last A is the A on ALPI's start cell
- **THEN** PASTA is not spelled
