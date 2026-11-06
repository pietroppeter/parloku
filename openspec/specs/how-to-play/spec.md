# how-to-play Specification

## Purpose
How Parloku tells a new player what to do: the three rules cards, the animated first lesson in the daily splash, and
the 🎓 tutorial on the first puzzle.

## Requirements

### Requirement: The rules in three cards
The game page SHALL show the rules in three short cards below the game: 01 sudoku (each letter once per row, column
and 2×3 box), 02 words (each word starts in its ringed cell and is spelled one step at a time, up, down, left or
right), 03 tiles (pull a tile from below, bring it back to merge).

#### Scenario: Reading the rules
- **WHEN** a player scrolls below the game
- **THEN** the three cards are there, in the page's language

### Requirement: Rules first, then gestures
Anything that teaches the game SHALL say the rules of the puzzle before the gestures, and SHALL be short enough to
read on a phone without scrolling much.

#### Scenario: A new explanation
- **WHEN** a page or card explains how to play
- **THEN** it opens with the rules, and the gestures come after

### Requirement: The first lesson
A first-time player SHALL be offered, in the daily splash, a short animated lesson that shows a tile being dragged
onto the board and a word being spelled; `?learn` opens it directly.

#### Scenario: First visit
- **WHEN** someone opens Parloku for the first time
- **THEN** the splash offers the lesson before the game

### Requirement: The tutorial
The 🎓 tutorial SHALL walk the first puzzle along the logical path (see `logical-path`), asking for the next step
after every drop and explaining it.

#### Scenario: Starting the tutorial
- **WHEN** the player opens `?tutorial`
- **THEN** the first puzzle starts with the coach asking for ITALIA's first letter
