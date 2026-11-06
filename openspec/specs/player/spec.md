# player Specification

## Purpose
The game page (`index.html`): what a player can do around the board, from choosing a puzzle to winning it.

## Requirements

### Requirement: The page opens on the game
The page SHALL open straight on a playable puzzle, and show only the game (see `play-screen`). On a day's first visit
it SHALL show the daily splash, which can be skipped (`?nosplash`) or shown again (`?splash=first`).

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
While playing, the page SHALL offer ↶ undo and ↷ redo with the menu (Pietro, 6 November 2026), and rifaccio, which
starts the puzzle again, right away, without asking. 💡 hint and 🔗 link SHALL stay hidden, on purpose.

↶ and ↷ SHALL be two round buttons that come down and go up with the menu, at the top right next to the first word,
apart from the menu's three buttons. ↶ SHALL take back the last change to the board, one at a time, back to the
puzzle's start; ↷ SHALL do a taken-back change again; a new move SHALL forget the changes that were taken back. A
button with nothing to do SHALL be shown faded. Tapping either SHALL keep the menu down for another 4 seconds.

For 8 seconds after a reset, or until the first move if that comes sooner, rifaccio SHALL read "annullo rifaccio" and
bring back the board, its undo and redo history, and the clock. A reset of an untouched board SHALL NOT offer it.

#### Scenario: Undo and redo with the menu
- **WHEN** the player has placed three letters and slides the menu down
- **THEN** ↶ and ↷ come down at the top right, ↶ ready and ↷ faded

#### Scenario: Two steps back, one forward
- **WHEN** the player taps ↶ twice and then ↷ once
- **THEN** the board loses its last two letters, gets the second-to-last back, and the menu stays down

#### Scenario: A new move forgets the redo
- **WHEN** the player taps ↶ and then makes a move
- **THEN** ↷ is faded

#### Scenario: No undo while playing
- **WHEN** the player drops a tile on the wrong cell while the menu is up
- **THEN** no ↶, ↷, 💡 or 🔗 button is on the screen, and a double tap sends the tile back below

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
