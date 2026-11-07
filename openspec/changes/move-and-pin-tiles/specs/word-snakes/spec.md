## MODIFIED Requirements

### Requirement: Moving a head
A drag of the head of an unfinished word that ends away from the word, on an empty cell the word did not grow to,
SHALL move the head there, like any letter on the board (Pietro, 7 November 2026: tiles on the board move). A head
that is pinned, or a given, SHALL leave a copy there instead and stay. Holding the head still SHALL pin it or unpin
it, as with any letter. This SHALL hold even when the finger crosses the cell before the head on its way.

#### Scenario: A drag off the word moves the head
- **WHEN** MAGIA has M A G I down the last column and the player drags the I straight away to r5c5, off the word
- **THEN** the I moves to r5c5 and MAGIA is left with M A G

```drag
puzzle: 2
start:
  . . . . . M
  . . . . . A
  . . . . . G
  . . . . . I
  . I O . . .
  . . . . I O
drag: r4c6 -> r5c5
end:
  . . . . . M
  . . . . . A
  . . . . . G
  . . . . . .
  . I O . I .
  . . . . I O
outline MAGIA: r1c6 r2c6 r3c6
```

#### Scenario: A pinned head copies
- **WHEN** MAGIA has M A G I down the last column, the I is pinned, and the player drags it to r5c5
- **THEN** r5c5 gets a copy of I and the pinned I stays at the end of MAGIA

```drag
puzzle: 2
start:
  . . . . . M
  . . . . . A
  . . . . . G
  . . . . . I
  . I O . . .
  . . . . I O
start pins: r4c6
drag: r4c6 -> r5c5
end:
  . . . . . M
  . . . . . A
  . . . . . G
  . . . . . I
  . I O . I .
  . . . . I O
outline MAGIA: r1c6 r2c6 r3c6 r4c6
end pins: r4c6
```

#### Scenario: Holding the head pins it
- **WHEN** MAGIA has M A G I down the last column and the player holds the I still
- **THEN** the I gets a pin and the word doesn't change

```drag
puzzle: 2
start:
  . . . . . M
  . . . . . A
  . . . . . G
  . . . . . I
  . I O . . .
  . . . . I O
long-press: r4c6
end:
  . . . . . M
  . . . . . A
  . . . . . G
  . . . . . I
  . I O . . .
  . . . . I O
outline MAGIA: r1c6 r2c6 r3c6 r4c6
end pins: r4c6
```

#### Scenario: Past the letter before, to a far cell
- **WHEN** MAGIA has M A G I down the last column and the player drags the I over the G before it and on to an empty
  cell far away
- **THEN** the I moves to that cell, and the G stays

```drag
puzzle: 2
start:
  . . . . . M
  . . . . . A
  . . . . . G
  . . . . . I
  . I O . . .
  . . . . I O
drag: r4c6 -> r3c6 -> r2c4
end:
  . . . . . M
  . . . I . A
  . . . . . G
  . . . . . .
  . I O . . .
  . . . . I O
outline MAGIA: r1c6 r2c6 r3c6
```

## ADDED Requirements

### Requirement: A finished word
When a word's outline covers all its letters, the word SHALL celebrate for a moment: its letters hop one after the
other, from the start to the head. For as long as the word stays finished, the eyes on its head SHALL be happy (two
small arcs, like ^ ^) instead of looking ahead. Every letter of a finished word SHALL be a copy source: dragging it
SHALL pull out a copy and leave the word whole, and holding it SHALL NOT pin it. Its head still shrinks the word when
dragged back onto the cell before it, and a double tap still cuts the word. The word that solves the puzzle SHALL get
the win party, not its own hop (Pietro, 7 November 2026: "quando il serpente è finito puoi duplicare dal serpente,
e andrebbe un pochettino celebrato").

#### Scenario: MAGIA is finished
- **WHEN** the player adds the last A of MAGIA
- **THEN** M A G I A hop one after the other and the eyes on the last A turn happy

#### Scenario: Copying from a finished word
- **WHEN** MAGIA is spelled down the last column and the player drags its G to r3c4
- **THEN** r3c4 gets a copy of G and MAGIA stays whole

```drag
puzzle: 2
start:
  . . . . . M
  . . . . . A
  . . . . . G
  . . . . . I
  . I O . . A
  . . . . I O
drag: r3c6 -> r3c4
end:
  . . . . . M
  . . . . . A
  . . . G . G
  . . . . . I
  . I O . . A
  . . . . I O
outline MAGIA: r1c6 r2c6 r3c6 r4c6 r5c6
```

#### Scenario: Copying the head of a finished word
- **WHEN** MAGIA is spelled down the last column and the player drags its last A straight away to r4c5
- **THEN** r4c5 gets a copy of A and MAGIA stays whole

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

#### Scenario: A finished word takes no pin
- **WHEN** MAGIA is spelled down the last column and the player holds its G still
- **THEN** nothing changes and there is no pin

```drag
puzzle: 2
start:
  . . . . . M
  . . . . . A
  . . . . . G
  . . . . . I
  . I O . . A
  . . . . I O
long-press: r3c6
end:
  . . . . . M
  . . . . . A
  . . . . . G
  . . . . . I
  . I O . . A
  . . . . I O
end pins:
```
