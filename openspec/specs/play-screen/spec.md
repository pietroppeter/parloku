# play-screen Specification

## Purpose
The game screen itself, piece by piece: what is on it, where, and what each piece tells the player.

## Requirements

### Requirement: The pieces in order
The game page SHALL show only the clue cards, the board and the six letters below it, top to bottom, on one screen
with nothing to scroll to; the menu (istruzioni, ancora!, rifaccio) SHALL slide down from the top on a tap above the
grid. The rules are told on the istruzioni page, and how the game is built is told in a devlog post. Nothing hidden
SHALL stay in the page for them.

#### Scenario: Opening the page
- **WHEN** the page is opened on a phone
- **THEN** the clues, the board and the six letters fill the screen, with no buttons above them and nothing below

### Requirement: Clue cards
Each word SHALL have a card in its colour above the board. Its letters SHALL colour in as they are spelled from the
start cell, it SHALL show a ✓ when the word is complete, and tapping it SHALL make the word's ring or outline wiggle
on the board.

#### Scenario: Tapping a clue
- **WHEN** the player taps the GIOCO card
- **THEN** the GIOCO ring at r2c2 wiggles for a moment

### Requirement: The board
The board SHALL be the classic mini sudoku grid: 36 cells in six 2×3 boxes, with thin lines between cells and thick
lines between boxes (`?grid=rounded` keeps the earlier rounded cells for now). It SHALL show the given letters with a
mark that they are fixed, each word's start mark or outline, and letters in conflict rolling like marbles (more over
a few seconds) instead of red cells.

#### Scenario: A clash
- **WHEN** two A share a row
- **THEN** both A roll from side to side, and no cell turns red

#### Scenario: The old grid
- **WHEN** the page is opened with `?grid=rounded`
- **THEN** the board shows the earlier rounded cells

#### Scenario: A clash while dragging
- **WHEN** the player holds a tile over a cell where it would clash
- **THEN** the landing preview shows the tile in that cell, and the letters roll once it is dropped there

### Requirement: The held tile and the landing preview
A held tile SHALL grow and cast a shadow, and the board SHALL show the tile in the cell it will land in, while the
other tiles slide to their places in the previewed board.

#### Scenario: Hovering between two cells
- **WHEN** the finger is between r1c2 and r1c3, nearer r1c3
- **THEN** the preview shows the tile in r1c3
