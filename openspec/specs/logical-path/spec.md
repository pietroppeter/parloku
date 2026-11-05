# logical-path Specification

## Purpose
Solving like a person: the moves the 🎓 tutorial teaches, in Pietro's order, each with a reason a player can check
on the board.

## Requirements

### Requirement: Pietro's method
The next logical step SHALL be found in this order: point out a wrong tile first; else put the first letter of a
word whose start cell is empty; else follow a word letter by letter, where the next letter is forced when only one
cell next to the previous one fits the sudoku and still lets the word be finished; else a sudoku single (a cell with
one candidate, or a letter with one place in a row, column or box); else reveal a cell.

#### Scenario: The first step of puzzle 1
- **WHEN** puzzle 1 has only its givens
- **THEN** the first step is "ITALIA starts in cell 1, so r1c1 is I"

#### Scenario: A wrong tile
- **WHEN** the board has a tile that differs from the solution
- **THEN** the next step says that tile is not right and asks to drag it back

### Requirement: Every step is explained
Every step SHALL come with a sentence that names the cells and the reason (which unit already has the letter, or why
a neighbour can't finish the word), in English and Italian.

#### Scenario: A forced word letter
- **WHEN** the step is a word letter with two neighbours that fit the sudoku
- **THEN** the sentence says why the other neighbour can't be used

### Requirement: The tutorial follows the player
The tutorial SHALL ask for the next step after every drop, so it copes with any order and with mistakes, and it SHALL
only use puzzles whose logical path reaches the end without reveals.

#### Scenario: Playing ahead of the tutorial
- **WHEN** the player places a correct tile the tutorial hasn't asked for yet
- **THEN** the tutorial goes on from the new board
