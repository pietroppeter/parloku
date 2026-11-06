## ADDED Requirements

### Requirement: Small letters and big letters
A swipe down that starts in an empty spot of the letters area below the board SHALL make the six letters small;
a swipe up that starts there SHALL make them big again. Small letters SHALL each keep a thin outline of the big
letter's size, and SHALL be grabbed anywhere inside it, as big letters are. The letters' size SHALL be saved with the
progress, and SHALL stay when the player picks another puzzle.

#### Scenario: Swipe down
- **WHEN** the letters are big and the player swipes down between the letters below the board
- **THEN** the letters are small and the board does not change

```drag
puzzle: 2
start:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
swipe: down
end:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
end small: on
```

#### Scenario: Swipe up
- **WHEN** the letters are small and the player swipes up between them
- **THEN** the letters are big again

```drag
puzzle: 2
small: on
start:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
swipe: up
end small: off
```

### Requirement: Writing a note
With small letters, dropping a letter on an empty cell SHALL write that letter there as a note, small, in the
letter's own spot of the cell (two rows of three, in the order of the letters below, as the builder's pencil marks).
The letter SHALL come from below, from any letter on the board (a given or a word's head too) or from a note, and
SHALL always be a copy: no tile moves, no word grows or shrinks, and the snake rules (see `word-snakes`) do not
apply. A cell SHALL hold any number of notes; writing a note the cell already has SHALL change nothing. A cell with a
letter SHALL take no notes. A letter whose six tiles are all on the board gives no notes.

#### Scenario: A note from below
- **WHEN** the letters are small and the player drags the A from below onto r3c3
- **THEN** r3c3 has the note A, and no letter is placed

```drag
puzzle: 2
small: on
start:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
drag: below A -> r3c3
end:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
end notes: r3c3 A
```

#### Scenario: Two notes in one cell
- **WHEN** r3c3 has the note A and the player drags the M from below onto it
- **THEN** r3c3 has the notes A and M

```drag
puzzle: 2
small: on
notes: r3c3 A
start:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
drag: below M -> r3c3
end notes: r3c3 AM
```

#### Scenario: The same note twice
- **WHEN** r3c3 has the note A and the player drags another A onto it
- **THEN** r3c3 still has just the note A

```drag
puzzle: 2
small: on
notes: r3c3 A
start:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
drag: below A -> r3c3
end notes: r3c3 A
```

#### Scenario: A note from a given
- **WHEN** the letters are small and the player drags the given I at r5c2 onto r3c3
- **THEN** r3c3 has the note I and the given stays

```drag
puzzle: 2
small: on
start:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
drag: r5c2 -> r3c3
end:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
end notes: r3c3 I
```

#### Scenario: A word's head gives a note, not its next letter
- **WHEN** MAGIA has only its M, the letters are small, and the player drags the M one cell down
- **THEN** r2c6 has the note M, MAGIA does not grow and the M stays

```drag
puzzle: 2
small: on
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
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
end notes: r2c6 M
outline MAGIA: r1c6
```

#### Scenario: A note from a note
- **WHEN** r3c3 has the note A and the player drags that note onto r3c4
- **THEN** both r3c3 and r3c4 have the note A

```drag
puzzle: 2
small: on
notes: r3c3 A
start:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
drag: note A r3c3 -> r3c4
end notes: r3c3 A, r3c4 A
```

#### Scenario: No notes on a full cell
- **WHEN** the letters are small and the player drags the A onto the given at r5c2
- **THEN** nothing is written

```drag
puzzle: 2
small: on
start:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
drag: below A -> r5c2
end notes: none
```

### Requirement: Rubbing out a note
With small letters, a double tap on a note SHALL rub it out, and the cell's other notes SHALL stay. A double tap on
an empty cell SHALL fill nothing, even a sure cell (see `tiles-and-dragging`). A double tap on a letter on the board
SHALL send it back as it does with big letters. The game SHALL never rub out notes by itself: notes are the player's
own, and rubbing out the wrong ones would be a hint.

#### Scenario: Rub out one note
- **WHEN** r3c3 has the notes A and M and the player double taps the A
- **THEN** r3c3 has only the note M

```drag
puzzle: 2
small: on
notes: r3c3 AM
start:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
double-tap: note A r3c3
end notes: r3c3 M
```

#### Scenario: No sure fill with small letters
- **WHEN** the letters are small and the player double taps MAGIA's empty start cell r1c6
- **THEN** nothing is placed

```drag
puzzle: 2
small: on
start:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
double-tap: r1c6
end:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
```

### Requirement: Notes with big letters
With big letters, notes SHALL show but SHALL NOT react to a touch: drags and double taps work as if the notes were
not there. A letter placed on a cell SHALL hide the cell's notes, and they SHALL come back when the letter leaves.
↺ restart SHALL clear the notes. Notes SHALL be saved with the progress.

#### Scenario: A letter over notes
- **WHEN** r1c6 has the notes A and M, the letters are big, and the player drags the M from below onto r1c6
- **THEN** r1c6 holds M and its notes are hidden

```drag
puzzle: 2
notes: r1c6 AM
start:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
drag: below M -> r1c6
end:
  . . . . . M
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
end notes: none
```

#### Scenario: The notes come back
- **WHEN** r1c6 holds M over the notes A and M, and the player double taps the M
- **THEN** the M goes back below and r1c6 shows its notes A and M again

```drag
puzzle: 2
notes: r1c6 AM
start:
  . . . . . M
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
double-tap: r1c6
end:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
end notes: r1c6 AM
```

#### Scenario: A double tap on a note with big letters
- **WHEN** r3c3 has the note A, the letters are big, and the player double taps the A
- **THEN** the note stays

```drag
puzzle: 2
notes: r3c3 A
start:
  . . . . . .
  . . . . . .
  . . . . . .
  . . . . . .
  . I O . . .
  . . . . I O
double-tap: note A r3c3
end notes: r3c3 A
```

#### Scenario: Restart clears the notes
- **WHEN** the board has notes and the player picks ↺ restart
- **THEN** the board is back to its givens with no notes, and the letters keep their size
