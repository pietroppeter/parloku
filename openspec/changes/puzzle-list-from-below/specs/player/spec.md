## MODIFIED Requirements

### Requirement: Changing puzzle
ancora! SHALL send the menu up, then the words off the screen one at a time, to the left and to the right in turn, and
the grid with its letters after them, and SHALL then raise the list of puzzles from the bottom, one row at a time
(Pietro, 6 November 2026). The list SHALL show every puzzle in order, each row with its number from 1, its three words
and a check box that is ticked once the puzzle is solved; the puzzle in play SHALL be highlighted. Picking a puzzle
SHALL fold the list down and bring the new puzzle's words and grid in from the sides. Tapping the puzzle in play, or the
space beside the rows, SHALL fold the list down and bring the same puzzle back as it was.

#### Scenario: The list rises
- **WHEN** the player has solved puzzles 1 and 3 and taps ancora!
- **THEN** the words and the grid leave to the sides, and rows 1 to 10 rise from the bottom with boxes 1 and 3 ticked

#### Scenario: From puzzle 1 to puzzle 4
- **WHEN** the player picks 4 ESTATE · MARE · SERATA from the list
- **THEN** the list folds down, ESTATE · MARE · SERATA's words and empty grid come in from the sides, and the link in
  the address bar changes to its code

#### Scenario: Changing your mind
- **WHEN** the player opens the list and taps the empty space above the rows
- **THEN** the list folds down and the same puzzle comes back with its letters where they were
