## MODIFIED Requirements

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
