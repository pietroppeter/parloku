## ADDED Requirements

### Requirement: Building by playing
The builder SHALL use the game's board, tiles and drag gestures. Each word SHALL have a small ring at the top that is
dragged onto a cell to start the word there, and the word SHALL grow from its head as in the game.

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
💾 SHALL copy a link that reopens the builder exactly as it is (`?s=`), and 🔗 SHALL copy the link to play the puzzle
(`?p=`).

#### Scenario: Reopening a draft
- **WHEN** the author opens a 💾 link
- **THEN** the builder shows the same letters, words, pins and letter order
