## MODIFIED Requirements

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
