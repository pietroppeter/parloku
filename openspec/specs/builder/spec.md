# builder Specification

## Purpose
The puzzle builder (`builder.html`): make a puzzle by playing it, with pencil marks and a live count of solutions
from puzzlepaw's solver, until one solution is left.

## Requirements

### Requirement: Building by playing
The builder SHALL use the game's board, tiles and drag gestures. Each word SHALL be listed at the top with a ring on its
right, dragged onto a cell to start the word there, and the word SHALL grow, shrink and move from its head as in the
game. Holding a letter below the board SHALL let the author reorder the six letters like a list (the others make
room), without touching the board.

#### Scenario: Starting a word
- **WHEN** the author drags MAGIA's ring onto r1c6
- **THEN** r1c6 gets M and MAGIA starts there

### Requirement: Pencil marks
Every empty cell SHALL show, in pencil, the letters it can still have in at least one complete grid that fits the
letters placed and all the words; a cell with none SHALL turn red. A double tap on a cell with one pencil mark SHALL
fill it in.

#### Scenario: No room left
- **WHEN** the placed letters leave a cell with no possible letter
- **THEN** that cell is red

### Requirement: Counting solutions
The builder SHALL count the complete grids that keep every placed letter and contain all the words, trying every start
for the words not yet placed, and show 0, the exact number up to 9, or 10+.

#### Scenario: Ready
- **WHEN** the count is 1
- **THEN** the puzzle made of the word starts and the pinned letters is ready, and 🔗 gives its play link

### Requirement: Givens are pinned
Letters placed in the builder SHALL be only for exploring; the author SHALL pin a letter (📌) to make it a given, and
the puzzle SHALL be the word starts plus the pinned letters.

#### Scenario: Pin a letter
- **WHEN** the author drags the pin onto a placed letter
- **THEN** the letter becomes a given in the play link

### Requirement: Save and share
💾 SHALL copy the puzzle as puzzlepaw JSON (letters in their order, pins, word starts, its solution and the builder's
state), with a note saying whether it has one solution, none or several; the JSON is what gets pasted to add the
puzzle to the game. A `?s=` link SHALL reopen the builder exactly as it was, and 🔗 SHALL copy the link to play the
puzzle (`?p=`).

#### Scenario: Saving a ready puzzle
- **WHEN** the count is 1 and the author taps 💾
- **THEN** the puzzle's JSON is copied, with a note that it can be added to the game

#### Scenario: Reopening a draft
- **WHEN** the author opens a `?s=` link
- **THEN** the builder shows the same letters, words, pins and letter order
