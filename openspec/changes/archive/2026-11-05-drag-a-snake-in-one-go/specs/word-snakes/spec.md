## MODIFIED Requirements

### Requirement: Growing a word from its head
Dragging the head of a word that is not finished (the last letter its outline covers) onto an empty cell right
next to it SHALL put the word's next letter there, and the head SHALL stay where it was. The held tile SHALL show
the next letter while it is over such a cell. Going on without lifting the finger to an empty cell next to the new
letter SHALL add the letter after it, and so on until the word is finished.

#### Scenario: One step down from M
- **WHEN** MAGIA has only its M and the player drags the M one cell down
- **THEN** that cell gets A and the M stays where it was

```drag
puzzle: 2
start:
  . . . . . M
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
drag: r1c6 -> r2c6
end:
  . . . . . M
  . . . . . A
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
outline MAGIA: r1c6 r2c6
```

#### Scenario: Several letters in one drag
- **WHEN** MAGIA has only its M and the player drags the M down two cells without lifting the finger
- **THEN** the word grows by A and then G, and no M is added or moved

```drag
puzzle: 2
start:
  . . . . . M
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
drag: r1c6 -> r2c6 -> r3c6
end:
  . . . . . M
  . . . . . A
  . . . . . G
  . . . . . .
  . I O . . .
  . . . . I O
outline MAGIA: r1c6 r2c6 r3c6
```

## ADDED Requirements

### Requirement: Shrinking a word
Dragging the head of a word back onto the cell before it SHALL take the head's letter off the board (back to its
stack), and going on backwards SHALL keep taking letters off, down to the word's first letter. Moving forward again
in the same drag SHALL grow the word as usual, so a wrong turn is fixed in one gesture.

#### Scenario: Back up two letters
- **WHEN** AMICA went down the first column as A M I C A and the player drags the last A up two cells
- **THEN** the A and the C go back to their stacks and AMI is left

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
