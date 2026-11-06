## ADDED Requirements

### Requirement: A snake shows where the menu is
Until the player has opened the menu once on a device, a little snake of four tiles spelling MENU, with the eyes of a
word head, SHALL come into the empty space at the top a few seconds after the game is on screen and say, in a speech
bubble, "psst! tocca qui: c'è il menu" (Pietro, 6 November 2026). It SHALL come once on each visit and once more after
a win, then saying "psst! tocca qui per un altro puzzle", and go away by itself after about 11 seconds. Where there is
no room above the words it SHALL sit in the free corner right of the first word, with its bubble right of the second.

The snake SHALL never take a tap, and SHALL never cover a word. It SHALL wait for the splash or the first lesson to
close, and SHALL NOT come in the tutorial, on the istruzioni practice boards or in the devlog posts. When the menu
comes down it SHALL go away at once, and it SHALL NOT come again on that device.

#### Scenario: A first visit
- **WHEN** a new player closes the splash and waits
- **THEN** a few seconds later the MENU snake comes into the empty space at the top and says "psst! tocca qui: c'è il menu"

#### Scenario: A short screen
- **WHEN** the game is open on an iPhone 13, which has no room above the words
- **THEN** the snake sits right of ITALIA and its bubble right of PASTA, over no word

#### Scenario: Found it
- **WHEN** the player taps the empty space while the snake is talking
- **THEN** the menu comes down, the snake goes away, and it does not come back on the next visit

#### Scenario: After a win
- **WHEN** a player who has never opened the menu solves a puzzle
- **THEN** after the party the snake comes back once and says "psst! tocca qui per un altro puzzle"
