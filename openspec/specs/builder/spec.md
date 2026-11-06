# builder Specification

## Purpose
The puzzle builder (`builder.html`): make a puzzle by playing it, with pencil marks and the solutions found shown
as numbered circles, until the word starts and the pinned letters leave one solution.

## Requirements

### Requirement: Building by playing
The builder SHALL use the game's board, look, tiles and drag gestures. Each word SHALL be listed at the top; dragging
its row (anywhere on it) onto a cell SHALL start the word there, a double tap on the row SHALL take the word off the
board, and the word SHALL grow, shrink and move from its head as in the game. Holding a letter below the board SHALL
let the author reorder the six letters like a list (the others make room), without touching the board.

#### Scenario: Starting a word
- **WHEN** the author drags MAGIA's row onto r1c6
- **THEN** r1c6 gets M and MAGIA starts there

#### Scenario: Taking a word off
- **WHEN** the author double taps MAGIA's row
- **THEN** MAGIA's letters leave the board

### Requirement: Pencil marks
Every empty cell SHALL show, in pencil, the letters it can still have in at least one complete grid that fits the
letters placed and all the words; a cell with none SHALL keep a light red tint (a builder warning, not a conflict).
A double tap on a cell with one pencil mark SHALL fill it in.

#### Scenario: No room left
- **WHEN** the placed letters leave a cell with no possible letter
- **THEN** that cell is tinted light red

### Requirement: Counting solutions
The builder SHALL find the complete grids that keep every placed letter and contain all the words, trying every start
for the words not yet placed, and show one numbered circle per solution under the board, up to 100 (with … when the search stopped early, and
"0 soluzioni" when the words don't fit). A grid SHALL count only if each word reads one way from its start, no word
uses a cell twice or shares one with another word, and no word makes a U-turn. Tapping a circle SHALL show that
solution in the pencil marks: the word letters in their word's colour, the other letters in black. The circles are
for exploring with every placed letter; whether the puzzle itself (word starts plus pins) has one solution is told
when it is saved (see Save and share).

#### Scenario: Ready
- **WHEN** the word starts and the pinned letters leave one solution and the author taps 💾
- **THEN** the note says the puzzle can be added to the game, and 🔗 gives its play link

#### Scenario: Looking at a solution
- **WHEN** the author taps circle 2
- **THEN** the pencil marks show the second solution and circle 2 is filled

#### Scenario: A word that reads two ways
- **WHEN** in a grid a word could be spelled along two different paths from its start
- **THEN** that grid is not counted

### Requirement: Word sets
The builder SHALL offer ready word sets along its top bar, and ✎ to type three words of its own; a set SHALL be
refused unless its words use exactly six letters with no letter twice in a row (see `game-rules`).

#### Scenario: Typing a set
- **WHEN** the author types NERO ROSA ORO with ✎
- **THEN** the builder loads its six letters (A E N O R S) and its three words

### Requirement: Givens are pinned
Letters placed in the builder SHALL be only for exploring; the author SHALL pin a letter (📌) to make it a given, and
the puzzle SHALL be the word starts plus the pinned letters. Holding a pinned letter SHALL take its pin off.

#### Scenario: Pin a letter
- **WHEN** the author drags the pin onto a placed letter
- **THEN** the letter becomes a given in the play link

### Requirement: Save and share
💾 SHALL copy the puzzle as puzzlepaw JSON (letters in their order, pins, word starts, its solution and the builder's
state), with a note saying whether it has one solution, none or several; the JSON is what gets pasted to add the
puzzle to the game. A `?s=` link SHALL reopen the builder exactly as it was, and 🔗 SHALL copy the link to play the
puzzle (`?p=`).

#### Scenario: Saving a ready puzzle
- **WHEN** the word starts and the pinned letters leave one solution and the author taps 💾
- **THEN** the puzzle's JSON is copied, with a note that it can be added to the game

#### Scenario: Reopening a draft
- **WHEN** the author opens a `?s=` link
- **THEN** the builder shows the same letters, words, pins and letter order
