# tiles-and-dragging Specification

## Purpose
The core gesture of the game: each letter is one tile below the board, and you pull copies off it onto the board. The drag is
declarative: for the tile being held, the game lists every board the drag can reach and shows the one that lands
the tile closest to the finger.

## Requirements

### Requirement: Tiles that divide
Below the board each of the six letters SHALL show as one tile (in two rows of three). Pulling it SHALL stretch a neck
from the letter until the copy splits off, and the letter left behind SHALL ripple; a copy brought back to its letter
before letting go SHALL reach out and merge into it. A letter has six copies: once all six are on the board, its spot
SHALL show an empty ring with a ✓, and nothing can be pulled from it.

#### Scenario: All A placed
- **WHEN** six A are on the board
- **THEN** the A spot below the board shows an empty ring with a ✓ and nothing to pull

### Requirement: Pulling a tile onto an empty cell
Dragging a letter from below SHALL pull out one copy, and releasing it within 0.6 of a cell from the centre of an empty
cell SHALL place it there. While the tile is held, the board SHALL already show where it will land.

#### Scenario: An A onto the first cell
- **WHEN** the player pulls an A from below onto r1c1
- **THEN** r1c1 holds A

```drag
puzzle: 2
start:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
drag: below A -> r1c1
end:
  A . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
```

#### Scenario: Let go far from every cell
- **WHEN** the player pulls an A from below and lets go far from the board
- **THEN** the copy goes back and merges into its letter, and the board doesn't change

```drag
puzzle: 2
start:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
drag: below A -> r3c3 -> off
end:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
```

### Requirement: Placed letters are never pushed out
A tile SHALL land only on an empty cell: dropping it on a letter already on the board SHALL NOT replace that
letter.

#### Scenario: Onto a given
- **WHEN** the player pulls an A from below onto the given I at r5c2
- **THEN** the I stays and the A goes back below

```drag
puzzle: 2
start:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
drag: below A -> r5c2
end:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
```

### Requirement: Givens stay put
A given letter SHALL NOT be moved or sent back. Dragging it, straight away or after holding it, SHALL pull a copy of
its letter and leave the given where it is.

#### Scenario: Holding a given
- **WHEN** the player holds the given I at r5c2 and then drags it up one cell
- **THEN** a copy of I lands on r4c2 and the given stays on r5c2

```drag
puzzle: 2
start:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
hold: r5c2 -> r4c2
end:
  . . . . . .
  . . . . . .
  . . . . . .
  . I . . . .
  . I O . . .
  . . . . I O
```

### Requirement: Copying and moving a placed letter
Dragging a letter on the board that is not the last letter of a word SHALL pull out a copy of it, as if from its
letter below, and leave the letter where it is. Holding the letter still for a moment (about a third of a second) before
dragging SHALL move the letter itself; let go away from every empty cell, it SHALL stay in its cell.

#### Scenario: A quick drag copies
- **WHEN** C is at r1c3 and the player drags it straight away to r3c4
- **THEN** there is a C at r1c3 and one at r3c4

```drag
puzzle: 2
start:
  . . C . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
drag: r1c3 -> r3c4
end:
  . . C . . .
  . . . . . .
  . . . C . .
  . . . . . .
  . I O . . .
  . . . . I O
```

#### Scenario: Hold, then drag, moves
- **WHEN** C is at r1c3 and the player holds it, then drags it to r3c4
- **THEN** the C is at r3c4 and r1c3 is empty

```drag
puzzle: 2
start:
  . . C . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
hold: r1c3 -> r3c4
end:
  . . . . . .
  . . . . . .
  . . . C . .
  . . . . . .
  . I O . . .
  . . . . I O
```

### Requirement: Double taps
A double tap on an empty start cell SHALL fill in its word's first letter. A double tap on an empty cell that is the
last gap of a row, column or box whose other five letters are all different SHALL fill in the missing letter. A
double tap on a placed letter that is not a given SHALL send it back below, into its letter; if the letter is in a word's
outline, the word SHALL be cut there: that letter and the ones after it go back (see `word-snakes`).

#### Scenario: The start of MAGIA
- **WHEN** r1c6 is empty and the player double taps it
- **THEN** r1c6 holds M

#### Scenario: The last gap in a row
- **WHEN** a row has five different letters and one empty cell, and the player double taps that cell
- **THEN** the cell gets the sixth letter
