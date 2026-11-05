# word-snakes Specification

## Purpose
How a word in progress shows and behaves on the board: its outline (the "snake") and the gestures on its last
letter (the head) that grow and move it.

## Requirements

### Requirement: The outline of a word
Every word SHALL be drawn on the board as an outline in the word's colour: a ring on its start cell while that cell
is empty, growing around the letters as they are spelled from it. The outline SHALL follow the longest part of the
word spelled so far from the start cell.

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
the next letter while it is over such a cell.

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
