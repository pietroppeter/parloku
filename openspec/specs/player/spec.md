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
an empty or wrong cell), rifaccio (starts the puzzle again, right away, without asking) and 🔗 link (copies a link to
this puzzle). For 8 seconds after a reset, or until the first move if that comes sooner, rifaccio SHALL read
"annullo rifaccio" and bring back the board, its undo history and the clock. A reset of an untouched board SHALL NOT
offer it.

#### Scenario: Undo after a wrong drop
- **WHEN** the player drops a tile and taps ↶
- **THEN** the board is as before the drop

#### Scenario: Hint with a wrong tile on the board
- **WHEN** one tile is wrong and the player taps 💡
- **THEN** a correct tile glides into a cell that was empty or wrong

#### Scenario: Reset by mistake
- **WHEN** the player taps rifaccio with ten tiles placed, then taps "annullo rifaccio" within 8 seconds
- **THEN** the ten tiles, the undo history and the clock are back

#### Scenario: The undo window closes
- **WHEN** the player taps rifaccio and then places a tile
- **THEN** the button reads rifaccio again

### Requirement: Winning
A solved board SHALL show a Bravo! banner with the moves and the time taken, and letter confetti.

#### Scenario: The last tile
- **WHEN** the last tile makes the grid solved
- **THEN** Bravo! appears with the number of moves and the time

### Requirement: Three buttons at the top
While playing, the top of the game SHALL show a menu of only three buttons: istruzioni, which opens a page with the
rules of the game and then the gameplay; ancora!, which lists the puzzles to pick another one, with the solved ones
ticked; and rifaccio, which starts the puzzle again and shows only once a letter is down. The menu SHALL slide down on
a tap above the grid and go back up after 4 seconds or on a tap in the game. Solved puzzles SHALL be remembered in the
browser.

#### Scenario: Picking another puzzle
- **WHEN** the player has solved puzzle 1 and taps ancora!
- **THEN** the list shows every puzzle, with puzzle 1 ticked

#### Scenario: Opening the menu
- **WHEN** the player taps the empty space above the grid
- **THEN** the three buttons slide down, and go back up 4 seconds later

#### Scenario: The instructions
- **WHEN** the player taps istruzioni
- **THEN** a page explains the rules first and then how to play, without a solving tutorial

### Requirement: Changing puzzle
ancora! SHALL show the puzzles sideways in place of the three buttons; tapping the current puzzle SHALL just close the
menu. Changing puzzle SHALL send the words, the grid and the letters out to the left one at a time, and bring the new
ones in from the right.

#### Scenario: From puzzle 1 to puzzle 2
- **WHEN** the player picks AMICA · GIOCO · MAGIA from the list
- **THEN** puzzle 1's pieces leave to the left one at a time and puzzle 2's come in from the right
