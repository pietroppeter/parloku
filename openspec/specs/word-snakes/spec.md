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
A drag of the head of a word that ends away from the word, on an empty cell the word did not grow to, SHALL leave a
copy of the head's letter there and keep the head where it is, as with any placed letter (Pietro, 6 November 2026:
"the head in general moves by growing the snake, but if the drag ends on cells the snake can't reach, it should copy").
Holding the head still for a moment before dragging SHALL move the head itself. This SHALL hold even when the finger
crosses the cell before the head on its way.

#### Scenario: A quick drag off the word copies
- **WHEN** MAGIA ends with an A one cell too low and the player drags that A straight away to a cell off the word
- **THEN** that cell gets a copy of A and the A at the end of MAGIA stays

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
  . I O . . A
  . . . . I O
outline MAGIA: r1c6 r2c6 r3c6 r4c6 r5c6
```

#### Scenario: A misplaced last letter
- **WHEN** MAGIA ends with an A one cell too low and the player holds that A, then drags it to the right cell
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
hold: r5c6 -> r4c5
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
- **WHEN** MAGIA ends with an A one cell too low and the player holds that A, drags it over the I before it and on
  to an empty cell far away
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
hold: r5c6 -> r4c6 -> r2c4
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

### Requirement: Sending a snake back
A double tap on a letter of a word's outline SHALL send that letter and every later letter of the word back below;
the letters before it SHALL stay, and givens SHALL always stay. A double tap on the word's first letter therefore
clears the whole word. A letter outside every outline goes back alone.

#### Scenario: Double tap inside MAGIA
- **WHEN** MAGIA is spelled down the last column and the player double taps its G
- **THEN** G, I and A go back below, and M A stay with the outline on them

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
  . . . . . M
  . . . . . A
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
outline MAGIA: r1c6 r2c6
```

#### Scenario: Double tap on the first letter
- **WHEN** MAGIA is spelled down the last column and the player double taps its M
- **THEN** all five letters go back below and MAGIA's start mark is empty again

```drag
puzzle: 2
start:
  . . . . . M
  . . . . . A
  . . . . . G
  . . . . . I
  . I O . . A
  . . . . I O
double-tap: r1c6
end:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
outline MAGIA:
```

### Requirement: Words never overlap
Two outlines SHALL NOT share a cell. A word's outline SHALL NOT enter another word's start cell, and where two
outlines could take the same letters, the longer one SHALL keep them (on a tie, the word listed first) and the other
SHALL be traced around them. Stretching a word SHALL NOT step onto another word's start cell.

#### Scenario: A letter on the next word's start
- **WHEN** PASTA has P A S T from r3c1 and the player puts an A on ALPI's start cell r5c1, next to the T
- **THEN** the A starts ALPI, and PASTA's outline stays on its four letters

```drag
puzzle: 1
start:
  . . . . P .
  . . . . . .
  P A . L . .
  T S . . . .
  . . . . . .
  . S . . . .
drag: below A -> r5c1
end:
  . . . . P .
  . . . . . .
  P A . L . .
  T S . . . .
  A . . . . .
  . S . . . .
outline PASTA: r3c1 r3c2 r4c2 r4c1
outline ALPI: r5c1
```

### Requirement: Laying a word from its start
Pressing on the empty start cell of a word and dragging SHALL put the word's first letter on the start cell as soon as
the finger moves, and each free cell next to the head that the finger then reaches SHALL get the word's next letter,
as in "Growing a word from its head" (Pietro, 6 November 2026). A tap on the start cell SHALL stay a tap.

#### Scenario: MAGIA in one drag from its start
- **WHEN** MAGIA's start cell is empty and the player drags from it down two cells
- **THEN** the start cell gets M, and the two cells below get A and G

```drag
puzzle: 2
start:
  . . . . . .
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
