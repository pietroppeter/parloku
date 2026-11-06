## MODIFIED Requirements

### Requirement: Building by playing
The builder SHALL use the game's board, look, tiles and drag gestures. Each word SHALL be listed at the top; dragging
its row (anywhere on it) onto a cell SHALL start the word there, a double tap on the row SHALL take the word off the
board, and the word SHALL grow, shrink and move from its head as in the game. Holding a letter below the board SHALL
let the author reorder the six letters like a list (the others make room), without touching the board.

#### Scenario: Starting a word
- **WHEN** the author drags MAGIA's row onto r1c6
- **THEN** r1c6 gets M and MAGIA starts there

#### Scenario: Taking a word off
- **WHEN** the author double taps MAGIA's row
- **THEN** MAGIA's letters leave the board

### Requirement: Pencil marks
Every empty cell SHALL show, in pencil, the letters it can still have in at least one complete grid that fits the
letters placed and all the words; a cell with none SHALL keep a light red tint (a builder warning, not a conflict).
A double tap on a cell with one pencil mark SHALL fill it in.

#### Scenario: No room left
- **WHEN** the placed letters leave a cell with no possible letter
- **THEN** that cell is tinted light red

### Requirement: Counting solutions
The builder SHALL find the complete grids that keep every placed letter and contain all the words, trying every start
for the words not yet placed, and show one numbered circle per solution under the board, up to 100. A grid SHALL count
only if each word reads one way from its start. Tapping a circle SHALL show that solution in the pencil marks.

#### Scenario: Ready
- **WHEN** there is one circle
- **THEN** the puzzle made of the word starts and the pinned letters is ready, and 🔗 gives its play link

#### Scenario: A word that reads two ways
- **WHEN** in a grid a word could be spelled along two different paths from its start
- **THEN** that grid is not counted
