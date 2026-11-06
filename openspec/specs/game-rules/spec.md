# game-rules Specification

## Purpose
The rules of Parloku as a puzzle, independent of how it is played on screen: a 6×6 mini sudoku spelled in six
letters, with words threaded through it as extra clues.

## Requirements

### Requirement: Sudoku in six letters
A puzzle SHALL use exactly six distinct letters, and a solved grid SHALL have each of them once in every row, every
column and every box (six boxes of two rows by three columns).

#### Scenario: A repeated letter in a row
- **WHEN** a row holds two A
- **THEN** the grid is not solved, and both cells count as clashing

#### Scenario: The boxes are two rows by three columns
- **WHEN** a letter is at r1c1 and the same letter at r2c3
- **THEN** they clash, because both are in the first box

### Requirement: Words are spelled one step at a time
Every word clue SHALL have a start cell, and a solved grid SHALL spell the word from that cell by moving at each
letter to the cell above, below, left or right of the previous one. Diagonal steps SHALL NOT count.

#### Scenario: A word down a column
- **WHEN** AMICA starts at r1c1 and the grid has A M I in the first column and C A to the right of the I
- **THEN** AMICA is spelled

#### Scenario: A diagonal step
- **WHEN** the only M next to a word's A is diagonal to it
- **THEN** the word is not spelled from there

### Requirement: Given letters
A puzzle MAY fix some letters in their cells (givens). A given SHALL be part of every solution and SHALL never be
moved or removed by the player.

#### Scenario: A given in the answer
- **WHEN** puzzle 2 gives I at r5c2
- **THEN** its solution has I at r5c2

### Requirement: One solution
A puzzle that is published (in `data/`) SHALL have exactly one solution, and it SHALL be
the answer key stored with it.

#### Scenario: A puzzle with two solutions
- **WHEN** the solver finds a second solution for a puzzle in `data/`
- **THEN** the build reports it, and the puzzle is not published until it has one

### Requirement: Word sets
The words of a puzzle SHALL use exactly the puzzle's six letters between them, SHOULD be three, SHOULD be loosely
linked in meaning, and SHALL NOT have the same letter twice in a row (it could never be spelled: two equal letters
next to each other share a row or a column).

#### Scenario: ITALIA PASTA ALPI
- **WHEN** the words are ITALIA, PASTA and ALPI
- **THEN** their letters are A I L P S T, six in all, and the set is valid

#### Scenario: A double letter
- **WHEN** a word is PIZZA
- **THEN** it is refused, because the two Z would sit next to each other
