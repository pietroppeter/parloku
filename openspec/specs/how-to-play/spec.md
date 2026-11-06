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
A first-time player SHALL be offered, in the daily splash, a short animated lesson; `?learn` opens it directly. It
SHALL explain the rules on its own small example (AMARENA, MENTA, MARE: each word in the colour of its outline), never
a puzzle of the game, in the game's look. From the moment the words are found in the grid, they SHALL stay above it
in their colours, as in the game, so each colour is linked to its word.
Like a puzzle of the game, the example SHALL have one solution, and no word in it SHALL turn back on itself in a U.
A finger SHALL then show each gesture on its own: dragging a letter onto a cell, a double tap on a word's start cell,
stretching a word, a double tap on the last free cell of a row, and a double tap that takes a word back from a
letter on. The lesson SHALL end with three choices: play alone, the guided tutorial (marked as a spoiler), or
istruzioni.

#### Scenario: First visit
- **WHEN** someone opens Parloku for the first time
- **THEN** the splash offers the lesson before the game

#### Scenario: No spoiler
- **WHEN** the lesson spells its words
- **THEN** they are AMARENA, MENTA and MARE, and no puzzle of the game is shown solved

#### Scenario: Words and colours
- **WHEN** the lesson shows the words in the grid and then the gestures
- **THEN** AMARENA, MENTA and MARE stay above the grid in red, green and blue, the colours of their start marks and outlines

#### Scenario: Both sure cells
- **WHEN** the lesson shows the gestures
- **THEN** the finger double taps a word's start cell and, in its own step, the last free cell of the bottom row

### Requirement: The tutorial
The 🎓 tutorial SHALL walk the first puzzle along the logical path (see `logical-path`), asking for the next step
after every drop and explaining it. It SHALL fit one phone screen like the game: its messages SHALL sit on
semi-transparent, white-ish blobs over the play area, and a blob SHALL NOT cover the cells, the letter or the clue the
current step is about; the player MAY drag a blob aside, and it stays there. Before it starts it SHALL warn that it
solves the first puzzle (a spoiler). It SHALL teach the gestures as they come up (a double tap on a sure cell,
stretching a word from its last letter, a double tap to take a letter back), in full the first time and by name after.
It opens with `?tutorial`, from the first lesson, and from a link on the istruzioni page.

#### Scenario: Starting the tutorial
- **WHEN** the player opens `?tutorial`
- **THEN** the first puzzle starts with the coach asking for ITALIA's first letter

#### Scenario: The tutorial on an iPhone 13
- **WHEN** the tutorial shows any step on an iPhone 13
- **THEN** the clues, the board and the six letters are where they are in the game, and the letters end above 664 px

#### Scenario: A blob out of the way
- **WHEN** a step asks for I at r1c1
- **THEN** the step's blob covers neither r1c1, nor the I below the board, nor the ITALIA clue

### Requirement: The istruzioni page
The istruzioni page (`istruzioni.html`, opened from the menu) SHALL give the rules first (letter sudoku, the three
words, fixed letters), then the gestures (place, copy, move, write a word, take back, fill a sure cell, find a word,
the menu), with no solving tutorial on the page itself. At the top it SHALL link to the first lesson (`?learn`) and
to the 🎓 tutorial (`?tutorial`, marked as a spoiler). Under every gesture, and for clashes, a practice board SHALL let the player try it
at once: the game in `?demo` mode, started from a position set up for that gesture, with no menu, saving nothing, and
a "↺ da capo" button to start again.

#### Scenario: Opening istruzioni
- **WHEN** the player taps istruzioni in the menu
- **THEN** a page explains the three rules, then the gestures, with a link back to the game

#### Scenario: From istruzioni to the lessons
- **WHEN** the player taps the first-lesson link or the tutorial link at the top of istruzioni
- **THEN** the game opens with the first lesson, or with the tutorial on the first puzzle

#### Scenario: Trying the sure cells
- **WHEN** the player double taps, on the practice board under "fill a sure cell", the last free cell of the first
  row, of the third column and of the bottom-right box, then the green start cell
- **THEN** each one gets its letter, and a double tap on any other empty cell places nothing

#### Scenario: Trying a gesture
- **WHEN** the player stretches a word on the practice board under "write a word"
- **THEN** the word grows as in the game, and the game's own saved board is untouched
