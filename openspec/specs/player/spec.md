# player Specification

## Purpose
The game page (`index.html`): what a player can do around the board, from choosing a puzzle to winning it.

## Requirements

### Requirement: The page opens on the game
The page SHALL open straight on a playable puzzle, with the game's explanation (the notebook) below it. On a day's
first visit it SHALL show the daily splash, which can be skipped (`?nosplash`) or shown again (`?splash=first`).

#### Scenario: First visit of the day
- **WHEN** a player opens the page for the first time today
- **THEN** the splash greets them, and closing it shows the puzzle ready to play

### Requirement: Choosing a puzzle
The puzzle choice SHALL list every puzzle the game ships, labelled by its three words, plus one opened from a link.
Picking a puzzle SHALL always start it afresh.

#### Scenario: Picking puzzle 2
- **WHEN** the player picks AMICA · GIOCO · MAGIA
- **THEN** its empty board is shown with the three clue cards, and the link in the address bar changes to its code

### Requirement: Progress is kept
The board of each puzzle SHALL be remembered in the browser, so coming back to the page continues where the player
left off.

#### Scenario: Reload in the middle
- **WHEN** the player has placed ten tiles and reloads the page
- **THEN** the ten tiles are still there

### Requirement: Undo, hint, reset, link
The page SHALL offer ↶ undo (takes back the last change, any number of times), 💡 hint (glides one correct tile into
an empty or wrong cell), ↺ reset (starts the puzzle again) and 🔗 link (copies a link to this puzzle).

#### Scenario: Undo after a wrong drop
- **WHEN** the player drops a tile and taps ↶
- **THEN** the board is as before the drop

#### Scenario: Hint with a wrong tile on the board
- **WHEN** one tile is wrong and the player taps 💡
- **THEN** a correct tile glides into a cell that was empty or wrong

### Requirement: Winning
A solved board SHALL show a Bravo! banner with the moves and the time taken, and letter confetti.

#### Scenario: The last tile
- **WHEN** the last tile makes the grid solved
- **THEN** Bravo! appears with the number of moves and the time
