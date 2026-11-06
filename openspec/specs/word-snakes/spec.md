# word-snakes Specification

## Purpose
How a word in progress shows and behaves on the board: its outline (the "snake") and the gestures on its last
letter (the head) that grow and move it.

## Requirements

### Requirement: The outline of a word
Every word SHALL be drawn on the board as an outline in the word's colour: a thin rounded square on its start cell
while the word has at most one letter, growing around the letters as they are spelled from it. The outline SHALL stay
inside its cells, so two words in cells side by side never touch, and SHALL follow the longest part of the word spelled
so far from the start cell.

#### Scenario: Two letters of MAGIA
- **WHEN** r1c6 holds M and r2c6 holds A
- **THEN** the MAGIA outline covers r1c6 and r2c6

```drag
puzzle: 2
start:
  . . . . . M
  . . . . . A
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
drag: none
outline MAGIA: r1c6 r2c6
```

### Requirement: The outline never steps back
A word's outline SHALL NOT use a cell twice, so a letter already in the word can't stand in for a later one.

#### Scenario: GIOC is not GIOCO
- **WHEN** GIOCO has G I O C in a row and no O after the C
- **THEN** the outline covers four cells, not five

```drag
puzzle: 2
start:
  . . . . . .
  . G I O C .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
drag: none
outline GIOCO: r2c2 r2c3 r2c4 r2c5
```

#### Scenario: GIOCO with its own last O
- **WHEN** an O is added below the C
- **THEN** the outline covers all five letters

```drag
puzzle: 2
start:
  . . . . . .
  . G I O C .
  . . . . O .
  . . . . . .
  . I O . . .
  . . . . I O
drag: none
outline GIOCO: r2c2 r2c3 r2c4 r2c5 r3c5
```

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

### Requirement: Moving a head
Dragging the head of a word to a cell that is not next to it SHALL move that tile, never copy it.

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

### Requirement: Shrinking a word
Dragging the head of a word back onto the cell before it SHALL take the head's letter off the board (back
below), and going on backwards SHALL keep taking letters off, down to the word's first letter. Moving forward again
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

### Requirement: Sending a snake back
A double tap on any letter of a word's outline SHALL send the whole word (every letter its outline covers that is not
a given) back below. A letter outside every outline goes back alone.

#### Scenario: Double tap inside MAGIA
- **WHEN** MAGIA is spelled down the last column and the player double taps its G
- **THEN** all five letters go back below and MAGIA's start ring is empty again

```drag
puzzle: 2
start:
  . . . . . M
  . . . . . A
  . . . . . G
  . . . . . I
  . I O . . A
  . . . . I O
double-tap: r3c6
end:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
outline MAGIA:
```
