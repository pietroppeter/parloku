## MODIFIED Requirements

### Requirement: Winning
When the last tile solves the board, the letters on the board SHALL dance for about three seconds, in one of three
dances picked at random (ripples from the last letter placed, the snakes, the letters), letter confetti SHALL fall, and then a banner
SHALL pop up with Evviva! 🥳, the moves and the time taken. The banner SHALL sit over the
empty letter trays, below the grid, so the solved board stays in view. The words the player reads SHALL suit any
player: no masculine-only words such as Bravo!. A board that was already solved when the page opened SHALL show the
banner at once, with no dance and no confetti. With reduced motion the letters SHALL stay still.

#### Scenario: The last tile
- **WHEN** the last tile makes the grid solved
- **THEN** the letters do one of the three dances, and then Evviva! 🥳 appears below the grid with the number of moves and the time

#### Scenario: Back to a solved puzzle
- **WHEN** the player opens a puzzle they already solved
- **THEN** Evviva! 🥳 is there at once and nothing dances
