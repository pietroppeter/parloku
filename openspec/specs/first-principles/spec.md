# first-principles Specification

## Purpose
The design method every Parloku screen is checked against, from the "Back to basics" devlog: ten plain steps from
Norman, Nielsen, Fitts and Gestalt. A change to a screen SHALL say which of them it touches.

## Requirements

### Requirement: Write the loop
Every screen SHALL have its loop written in one sentence, and every piece on it SHALL help a step of that loop, its
start or its end. For the game: look at the clues and the board, pick a letter from a stack, drop it on a cell, see
if it fits; before: choose a puzzle; after: Bravo!.

#### Scenario: A new button
- **WHEN** a change adds a piece to the game screen
- **THEN** it names the step of the loop the piece helps, or it doesn't go on the screen

### Requirement: One job per piece, sorted by when it's needed
Every piece SHALL have one job, and no two pieces the same job. Pieces needed always SHALL get the space and the
middle; pieces needed once SHALL be out of the way; pieces never needed while playing SHALL leave the play area.

#### Scenario: A stats line
- **WHEN** a piece repeats what the stacks already show
- **THEN** it is cut

### Requirement: The whole loop on one screen
On a phone (an iPhone 13 shows 664 px of page) the clues, the board and the stacks SHALL be visible together, so the
player never scrolls while dragging.

#### Scenario: The game on an iPhone 13
- **WHEN** the game page is open on an iPhone 13
- **THEN** the stacks end above 664 px

### Requirement: Things that work together sit together
Each piece SHALL sit next to what it works with: clues right above the board, stacks right below, actions under the
stacks, the before-you-play choices in one row.

#### Scenario: The language switch
- **WHEN** the screen is laid out
- **THEN** the language switch sits in the row with the tutorial and the puzzle choice

### Requirement: One signal, one meaning
A colour, shape or mark SHALL mean one thing everywhere (see `theming`), and important meanings SHOULD have a second
cue besides colour.

#### Scenario: A selected tile
- **WHEN** something needs to look selected
- **THEN** it doesn't use a letter's colour or red

### Requirement: Every action gets an answer
Every touch SHALL get an answer right away, and a drag SHALL show what will happen before it happens.

#### Scenario: Phones have no hover
- **WHEN** something works on mouse hover
- **THEN** it also works with a tap

### Requirement: Mistakes are cheap
Any change to the board SHALL be undoable, and the one action that wipes the board SHALL be undoable or ask first.

#### Scenario: Reset
- **WHEN** the player taps ↺ reset by mistake
- **THEN** they can get their board back

### Requirement: Fit fingers
Everything tapped on a touch screen SHALL be at least 44 px tall.

#### Scenario: The action buttons on a phone
- **WHEN** the page is on a touch screen
- **THEN** undo, hint, reset and link are 44 px tall

### Requirement: Watch a real player
A change to a gesture or a screen SHALL be tried by a real player before it is called done, and their hesitations SHALL
become scenarios.

#### Scenario: A playtest finds a bug
- **WHEN** a playtester can't move a word's last letter
- **THEN** the case is written as a drag scenario before it is fixed
