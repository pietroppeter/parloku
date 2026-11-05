# play-screen Specification

## Purpose
The game screen itself, piece by piece, as the "Back to basics" devlog left it: what is on it, where, and what each
piece tells the player.

## Requirements

### Requirement: The pieces in order
The play area SHALL show, top to bottom: the row with 🎓 tutorial, the puzzle choice and EN / IT; the clue cards; the
board; the six letter stacks; the actions (undo, hint, reset, link). The rules cards and the skin switch SHALL come
after the play area, and the notebook explaining the code after them.

#### Scenario: Opening the page
- **WHEN** the page is opened on a phone
- **THEN** the first thing under the title is the row of choices, then the clues

### Requirement: Clue cards
Each word SHALL have a card in its colour above the board. Its letters SHALL colour in as they are spelled from the
start cell, it SHALL show a ✓ when the word is complete, and tapping it SHALL make the word's ring or outline wiggle
on the board.

#### Scenario: Tapping a clue
- **WHEN** the player taps the GIOCO card
- **THEN** the GIOCO ring at r2c2 wiggles for a moment

### Requirement: The board
The board SHALL show 36 cells in six 2×3 boxes with thick box lines, every cell with a faint edge, the given letters
with a mark that they are fixed, each word's start ring or outline, and red cells where a letter clashes (hidden while
a tile is held).

#### Scenario: A clash while dragging
- **WHEN** the player holds a tile over a cell where it would clash
- **THEN** the landing preview shows, without red, and the red shows after the drop

### Requirement: The held tile and the landing preview
A held tile SHALL grow and cast a shadow, and the board SHALL show the tile in the cell it will land in, while the
other tiles slide to their places in the previewed board.

#### Scenario: Hovering between two cells
- **WHEN** the finger is between r1c2 and r1c3, nearer r1c3
- **THEN** the preview shows the tile in r1c3
