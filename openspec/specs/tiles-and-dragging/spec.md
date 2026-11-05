# tiles-and-dragging Specification

## Purpose
The core gesture of the game: letters are tiles that you drag from their stacks onto the board. The drag is
declarative: for the tile being held, the game lists every board the drag can reach and shows the one that lands
the tile closest to the finger.

## Requirements

### Requirement: Stacks of tiles
Every letter SHALL have six tiles, which sit stacked on that letter's spot below the board until placed, so the
player sees one tile per letter. A letter whose six tiles are all placed SHALL show an empty spot with a ✓.

#### Scenario: All A placed
- **WHEN** six A are on the board
- **THEN** the A spot below the board shows a ✓ and nothing to pull

### Requirement: Pulling a tile onto an empty cell
Dragging from a stack SHALL pull out one tile, and releasing it within 0.6 of a cell from the centre of an empty
cell SHALL place it there. While the tile is held, the board SHALL already show where it will land.

#### Scenario: An A onto the first cell
- **WHEN** the player drags an A from its stack onto r1c1
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
drag: stack A -> r1c1
end:
  A . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
```

#### Scenario: Let go far from every cell
- **WHEN** the player drags an A from its stack and lets go far from the board
- **THEN** the tile goes back to its stack and the board doesn't change

```drag
puzzle: 2
start:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
drag: stack A -> r3c3 -> off
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
- **WHEN** the player drags an A from its stack onto the given I at r5c2
- **THEN** the I stays and the A goes back to its stack

```drag
puzzle: 2
start:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
drag: stack A -> r5c2
end:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
```

### Requirement: Givens stay put
A given letter SHALL NOT be moved or sent back. Like any letter on the board, it SHALL give a copy when dragged
straight away.

#### Scenario: Holding a given
- **WHEN** the player holds the given I at r5c2 and then drags it
- **THEN** nothing moves

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
grab: refused
```

### Requirement: Copying and moving a placed letter
Dragging a letter on the board that is not the last letter of a word SHALL pull out a copy of it, as if from its
stack, and leave the letter where it is. Holding the letter still for a moment (about a third of a second) before
dragging SHALL move the letter itself.

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
double tap on a placed letter that is not a given SHALL send it back to its stack.

#### Scenario: The start of MAGIA
- **WHEN** r1c6 is empty and the player double taps it
- **THEN** r1c6 holds M

#### Scenario: The last gap in a row
- **WHEN** a row has five different letters and one empty cell, and the player double taps that cell
- **THEN** the cell gets the sixth letter
