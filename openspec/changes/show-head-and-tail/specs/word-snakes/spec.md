## MODIFIED Requirements

### Requirement: The outline of a word
Every word SHALL be drawn on the board as an outline in the word's colour: a thin rounded square on its start cell
while the word has at most one letter, growing around the letters as they are spelled from it. The outline SHALL stay
inside its cells, so two words in cells side by side never touch, and SHALL follow the longest part of the word spelled
so far from the start cell. The start cell SHALL hold a soft tint of the word's colour, under its letter, so the
player sees where the word starts. Once the outline covers two letters or more, its head (the last letter it covers)
SHALL have two small eyes on its front edge, on the outline, looking the way the last step went, so the player sees
where the word has got to and which way it is going. The outline SHALL be equally thin everywhere (Pietro, 6 November
2026: tell the start from the head).

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

#### Scenario: Where ITALIA starts and where it has got to
- **WHEN** puzzle 1 has I T A on r1c1 r1c2 r1c3 and L on r2c3
- **THEN** the ITALIA outline covers those four cells, r1c1 is tinted red under the I, and the L has two eyes on the
  outline's bottom edge, looking down

```drag
puzzle: 1
start:
  I T A . P .
  . . L . . .
  . . . L . .
  . . . . . .
  . . . . . .
  . S . . . .
drag: none
outline ITALIA: r1c1 r1c2 r1c3 r2c3
```

#### Scenario: A word with no letters yet
- **WHEN** a word has no letter on the board
- **THEN** its start cell shows the thin rounded square and the tint, and there are no eyes

