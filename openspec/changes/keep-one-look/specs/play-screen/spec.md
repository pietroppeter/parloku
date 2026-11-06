## MODIFIED Requirements

### Requirement: The board
The board SHALL be the classic mini sudoku grid, and only that: 36 cells in six 2×3 boxes, with thin lines between
cells and thick lines between boxes. It SHALL show the given letters with a mark that they are fixed, each word's
start mark or outline, and letters in conflict rolling like marbles (more over a few seconds) instead of red cells.

#### Scenario: A clash
- **WHEN** two A share a row
- **THEN** both A roll from side to side, and no cell turns red

#### Scenario: The old grid
- **WHEN** the page is opened with `?grid=rounded`
- **THEN** the board still shows the classic grid

#### Scenario: A clash while dragging
- **WHEN** the player holds a tile over a cell where it would clash
- **THEN** the landing preview shows the tile in that cell, and the letters roll once it is dropped there
