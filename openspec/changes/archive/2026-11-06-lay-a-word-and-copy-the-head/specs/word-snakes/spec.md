## ADDED Requirements

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

## MODIFIED Requirements

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
