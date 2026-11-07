## MODIFIED Requirements

### Requirement: Givens stay put
A given letter SHALL NOT be moved or sent back. A given SHALL work as a letter pinned from the start, without the pin
drawn: dragging it, straight away or after holding it, SHALL pull a copy of its letter and leave the given where it is,
and holding it SHALL NOT pin it.

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
end pins:
```

#### Scenario: A quick drag of a given
- **WHEN** the player drags the given O at r6c6 straight away to r3c3
- **THEN** a copy of O lands on r3c3 and the given stays

```drag
puzzle: 2
start:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
drag: r6c6 -> r3c3
end:
  . . . . . .
  . . . . . .
  . . O . . .
  . . . . . .
  . I O . . .
  . . . . I O
```

### Requirement: Copying and moving a placed letter
Dragging a letter on the board SHALL move it, unless it is a copy source: let go on an empty cell it SHALL land there,
let go elsewhere on the board it SHALL stay in its cell, and let go below the board it SHALL go back to its letter.
Copies SHALL come only from the letters below the board, from a given, from a pinned letter and from any letter of a
finished word: dragging one of those SHALL pull out a copy and leave it where it is (Pietro, 7 November 2026, after
watching Emilia play: she let go of a tile too early, and dragging it on made a copy instead of moving it).

#### Scenario: A drag moves
- **WHEN** C is at r1c3 and the player drags it straight away to r3c4
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
drag: r1c3 -> r3c4
end:
  . . . . . .
  . . . . . .
  . . . C . .
  . . . . . .
  . I O . . .
  . . . . I O
```

#### Scenario: Onto a letter, it stays
- **WHEN** C is at r1c3 and the player drags it onto the given I at r5c2
- **THEN** the C stays at r1c3

```drag
puzzle: 2
start:
  . . C . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
drag: r1c3 -> r5c2
end:
  . . C . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
```

#### Scenario: Back below
- **WHEN** C is at r1c3 and the player drags it down to its letter below the board
- **THEN** the C goes back below and r1c3 is empty

```drag
puzzle: 2
start:
  . . C . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
drag: r1c3 -> below C
end:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
```

## ADDED Requirements

### Requirement: Pinning a letter
Holding a letter on the board still for about half a second SHALL pin it: the builder's pin (📌) SHALL show on the
tile's top right corner while the finger is still down, and the phone SHALL buzz. A pinned letter SHALL stay in its
cell, and dragging it SHALL pull out a copy, as from its letter below; if the finger moves on once the pin shows, that
same gesture SHALL drag the copy. Holding a pinned letter still again SHALL take its pin off. A pin SHALL go away when
its letter leaves the board (a double tap, or ↶). Pins SHALL be saved with the board, and ↶ and ↷ SHALL undo and redo
a pin like a move, without counting it as one. Givens and the letters of a finished word are copy sources already and
SHALL NOT take a pin (Pietro, 7 November 2026: "fai un long press, metti il pin, e long press, togli il pin").

#### Scenario: A long press pins
- **WHEN** C is at r1c3 and the player holds it still, then lets go
- **THEN** the C stays at r1c3 with a pin

```drag
puzzle: 2
start:
  . . C . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
long-press: r1c3
end:
  . . C . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
end pins: r1c3
```

#### Scenario: A pinned letter gives copies
- **WHEN** C is pinned at r1c3 and the player drags it to r3c4
- **THEN** there is a C at r1c3, still pinned, and one at r3c4

```drag
puzzle: 2
start:
  . . C . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
start pins: r1c3
drag: r1c3 -> r3c4
end:
  . . C . . .
  . . . . . .
  . . . C . .
  . . . . . .
  . I O . . .
  . . . . I O
end pins: r1c3
```

#### Scenario: Pin and copy in one gesture
- **WHEN** C is at r1c3 and the player holds it until the pin shows, then drags on to r3c4
- **THEN** the C at r1c3 is pinned and a copy is at r3c4

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
  . . C . . .
  . . . . . .
  . . . C . .
  . . . . . .
  . I O . . .
  . . . . I O
end pins: r1c3
```

#### Scenario: A second long press unpins
- **WHEN** C is pinned at r1c3 and the player holds it still again
- **THEN** the pin goes and the C stays

```drag
puzzle: 2
start:
  . . C . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
start pins: r1c3
long-press: r1c3
end:
  . . C . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
end pins:
```

#### Scenario: Unpinned, it moves again
- **WHEN** C is pinned at r1c3 and the player holds it until the pin goes, then drags it to r3c4
- **THEN** the C moves to r3c4, without a pin

```drag
puzzle: 2
start:
  . . C . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
start pins: r1c3
hold: r1c3 -> r3c4
end:
  . . . . . .
  . . . . . .
  . . . C . .
  . . . . . .
  . I O . . .
  . . . . I O
end pins:
```

#### Scenario: A double tap takes the pin away
- **WHEN** C is pinned at r1c3 and the player double taps it
- **THEN** the C goes back below with its pin

```drag
puzzle: 2
start:
  . . C . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
start pins: r1c3
double-tap: r1c3
end:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
end pins:
```
