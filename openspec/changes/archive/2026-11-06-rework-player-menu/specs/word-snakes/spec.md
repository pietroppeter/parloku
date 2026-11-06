## MODIFIED Requirements

### Requirement: The outline of a word
Every word SHALL be drawn on the board as an outline in the word's colour: a thin rounded square on its start cell
while the word has at most one letter, growing around the letters as they are spelled from it. The outline SHALL stay
inside its cells, so two words in cells side by side never touch, and SHALL follow the longest part of the word spelled
so far from the start cell.

#### Scenario: Two letters of MAGIA
- **WHEN** r1c6 holds M and r2c6 holds A
- **THEN** the MAGIA outline covers r1c6 and r2c6

```drag
puzzle: 2
start:
  . . . . . M
  . . . . . A
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
drag: none
outline MAGIA: r1c6 r2c6
```
