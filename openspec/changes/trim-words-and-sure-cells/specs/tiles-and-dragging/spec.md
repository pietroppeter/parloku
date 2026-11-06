## MODIFIED Requirements

### Requirement: Double taps
A double tap on an empty cell SHALL fill it only when the cell is sure: a word's empty start cell (it gets the word's
first letter), or the last free cell of a row, column or box whose other five letters are all different (it gets the
missing letter). A double tap on any other empty cell SHALL do nothing, even when only one letter could go there. A
double tap on a placed letter that is not a given SHALL send it back below, into its letter; if the letter is in a
word's outline, it and the word's later letters SHALL go back (see `word-snakes`).

#### Scenario: The start of MAGIA
- **WHEN** r1c6 is empty and the player double taps it
- **THEN** r1c6 holds M

#### Scenario: The last gap in a row
- **WHEN** a row has five different letters and one empty cell, and the player double taps that cell
- **THEN** the cell gets the sixth letter

#### Scenario: Not a sure cell
- **WHEN** the board has only puzzle 2's givens and the player double taps r3c3
- **THEN** nothing is placed

```drag
puzzle: 2
start:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
double-tap: r3c3
end:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
```
