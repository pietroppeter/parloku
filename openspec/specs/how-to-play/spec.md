# how-to-play Specification

## Purpose
How Parloku tells a new player what to do: the istruzioni page, the animated first lesson in the daily splash, and the
🎓 tutorial on the first puzzle.

## Requirements

### Requirement: The rules in three cards
The rules SHALL fit in three short cards: 01 sudoku (each letter once per row, column and 2×3 box), 02 words (each
word starts in its marked cell and is spelled one step at a time, up, down, left or right), 03 tiles (one tile per
letter below the board: pull it and it divides, bring the copy back and they merge). Since the menu rework (#13) the
cards are not shown on the game page; the istruzioni page tells the same rules.

#### Scenario: Reading the rules
- **WHEN** a player wants the rules while playing
- **THEN** the menu's istruzioni opens them, rules first

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
after every drop and explaining it. Since #13 it has no button on the game page: it opens with `?tutorial`, and the
first lesson hands over to it.

#### Scenario: Starting the tutorial
- **WHEN** the player opens `?tutorial`
- **THEN** the first puzzle starts with the coach asking for ITALIA's first letter

### Requirement: The istruzioni page
The istruzioni page (`istruzioni.html`, opened from the menu) SHALL give the rules first (letter sudoku, the three
words, fixed letters), then the gestures (place, copy, move, write a word, take back, fill a sure cell, find a word,
the menu), with no solving tutorial.

#### Scenario: Opening istruzioni
- **WHEN** the player taps istruzioni in the menu
- **THEN** a page explains the three rules, then the gestures, with a link back to the game
