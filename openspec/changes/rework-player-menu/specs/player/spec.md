## ADDED Requirements

### Requirement: Three buttons at the top
The top of the game SHALL show only three buttons: istruzioni, which opens a page with the rules of the game and then
the gameplay; ancora!, which lists the puzzles to pick another one, with the solved ones ticked; and rifaccio, which
starts the puzzle again. Solved puzzles SHALL be remembered in the browser.

#### Scenario: Picking another puzzle
- **WHEN** the player has solved puzzle 1 and taps ancora!
- **THEN** the list shows every puzzle, with puzzle 1 ticked

#### Scenario: The instructions
- **WHEN** the player taps istruzioni
- **THEN** a page explains the rules first and then how to play, without a solving tutorial

## MODIFIED Requirements

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
