## MODIFIED Requirements

### Requirement: The istruzioni page
The istruzioni page (`istruzioni.html`, opened from the menu) SHALL give the rules first (letter sudoku, the three
words, fixed letters), then the gestures as a gallery of cards swiped from right to left, one gesture per card (place, copy, move, write a word, take back, fill a sure cell, find a word,
the menu), then how sharing a solved game works, with an example, with no solving tutorial on the page itself. A table of
contents near the top SHALL link to the rules, the gestures and sharing. At the top it SHALL link to the first lesson (`?learn`) and
to the 🎓 tutorial (`?tutorial`, marked as a spoiler). Under every gesture, and for clashes, a practice board SHALL let the player try it
at once: the game in `?demo` mode, started from a position set up for that gesture, with no menu, saving nothing, and
a "↺ da capo" button to start again.

#### Scenario: Opening istruzioni
- **WHEN** the player taps istruzioni in the menu
- **THEN** a page explains the three rules, then the gestures, with a link back to the game

#### Scenario: From istruzioni to the lessons
- **WHEN** the player taps the first-lesson link or the tutorial link at the top of istruzioni
- **THEN** the game opens with the first lesson, or with the tutorial on the first puzzle

#### Scenario: Trying the sure cells
- **WHEN** the player double taps, on the practice board under "fill a sure cell", the last free cell of the first
  row, of the third column and of the bottom-right box, then the green start cell
- **THEN** each one gets its letter, and a double tap on any other empty cell places nothing

#### Scenario: Trying a gesture
- **WHEN** the player stretches a word on the practice board under "write a word"
- **THEN** the word grows as in the game, and the game's own saved board is untouched

#### Scenario: The gesture gallery
- **WHEN** the player swipes left on a gesture card in istruzioni
- **THEN** the next gesture's card slides in, with its own practice board

#### Scenario: How sharing works
- **WHEN** the player taps "Condividere" in the table of contents
- **THEN** the page scrolls to an example share and what its balls, ⭐, 🥳 and dance emoji mean
