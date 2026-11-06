## ADDED Requirements

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
