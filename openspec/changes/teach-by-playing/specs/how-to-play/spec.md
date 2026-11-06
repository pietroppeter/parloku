## MODIFIED Requirements

### Requirement: The first lesson
A first-time player SHALL be offered, in the daily splash, a short animated lesson that shows a tile being dragged
onto the board and a word being spelled; `?learn` opens it directly. The lesson SHALL use its own small example
(NERO, ROSA, ORO), never a puzzle of the game, and SHALL look like the game.

#### Scenario: First visit
- **WHEN** someone opens Parloku for the first time
- **THEN** the splash offers the lesson before the game

#### Scenario: No spoiler
- **WHEN** the lesson spells its words
- **THEN** they are NERO, ROSA and ORO, and no puzzle of the game is shown solved

### Requirement: The istruzioni page
The istruzioni page (`istruzioni.html`, opened from the menu) SHALL give the rules first (letter sudoku, the three
words, fixed letters), then the gestures (place, copy, move, write a word, take back, fill a sure cell, find a word,
the menu), with no solving tutorial. Under every gesture, and for clashes, a practice board SHALL let the player try it
at once: the game in `?demo` mode, started from a position set up for that gesture, with no menu, saving nothing, and
a "↺ da capo" button to start again.

#### Scenario: Opening istruzioni
- **WHEN** the player taps istruzioni in the menu
- **THEN** a page explains the three rules, then the gestures, with a link back to the game

#### Scenario: Trying a gesture
- **WHEN** the player stretches a word on the practice board under "write a word"
- **THEN** the word grows as in the game, and the game's own saved board is untouched
