## MODIFIED Requirements

### Requirement: Moving a head
Dragging the head of a word to a cell that is not next to it SHALL move that tile, never copy it. This SHALL hold
even when the finger crosses the cell before the head on its way (Pietro, 6 November 2026: moving SERATA's last A
up and to the right took it off the board, because the finger went over the T).

#### Scenario: A misplaced last letter
- **WHEN** MAGIA ends with an A one cell too low and the player drags that A to the right cell
- **THEN** the A moves there and its old cell is empty

```drag
puzzle: 2
start:
  . . . . . M
  . . . . . A
  . . . . . G
  . . . . . I
  . I O . . A
  . . . . I O
drag: r5c6 -> r4c5
end:
  . . . . . M
  . . . . . A
  . . . . . G
  . . . . A I
  . I O . . .
  . . . . I O
outline MAGIA: r1c6 r2c6 r3c6 r4c6 r4c5
```

#### Scenario: Past the letter before, to a far cell
- **WHEN** MAGIA ends with an A one cell too low and the player drags that A over the I before it and on to an empty
  cell far away
- **THEN** the A moves to that cell, and the I stays

```drag
puzzle: 2
start:
  . . . . . M
  . . . . . A
  . . . . . G
  . . . . . I
  . I O . . A
  . . . . I O
drag: r5c6 -> r4c6 -> r2c4
end:
  . . . . . M
  . . . A . A
  . . . . . G
  . . . . . I
  . I O . . .
  . . . . I O
outline MAGIA: r1c6 r2c6 r3c6 r4c6
```

### Requirement: Shrinking a word
Dragging the head of a word back onto the cell before it SHALL take the head's letter off the board (back
below) when the player lets go there, goes on backwards, or turns from there onto a free cell next to it; going on
backwards SHALL keep taking letters off, down to the word's first letter. Going from the cell before on to any other
cell SHALL NOT take a letter off: the drag is then a move. Moving forward again
in the same drag SHALL grow the word as usual, so a wrong turn is fixed in one gesture.

#### Scenario: Back up two letters
- **WHEN** AMICA went down the first column as A M I C A and the player drags the last A up two cells
- **THEN** the A and the C go back below and AMI is left

```drag
puzzle: 2
start:
  A . . . . .
  M . . . . .
  I . . . . .
  C . . . . .
  A I O . . .
  . . . . I O
drag: r5c1 -> r4c1 -> r3c1
end:
  A . . . . .
  M . . . . .
  I . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
outline AMICA: r1c1 r2c1 r3c1
```

#### Scenario: Fix a wrong turn in one drag
- **WHEN** AMICA went down as A M I C A and the player drags the last A up to the I and then right twice
- **THEN** the word ends as A M I in the column, then C and A to the right of the I

```drag
puzzle: 2
start:
  A . . . . .
  M . . . . .
  I . . . . .
  C . . . . .
  A I O . . .
  . . . . I O
drag: r5c1 -> r4c1 -> r3c1 -> r3c2 -> r3c3
end:
  A . . . . .
  M . . . . .
  I C A . . .
  . . . . . .
  . I O . . .
  . . . . I O
outline AMICA: r1c1 r2c1 r3c1 r3c2 r3c3
```
