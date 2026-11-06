## Why

Pietro, 6 November 2026, playing 0.2 before the playtest, found two snake gestures that felt wrong:

1. A quick drag of a word's head to a far cell moved the head. Every other placed letter is copied by a quick drag and
   moved only after a hold, so the head was the odd one out. The spec said so on purpose ("Moving a head", written
   that morning after SERATA's A left the board). Pietro chose to make the head behave like the other letters: "the head
   in general moves by growing the snake, but if the drag ends on cells the snake can't reach, it should copy".
2. He tends to start a word from its empty start square and drag from there. Nothing happened, because an empty cell
   has no tile to grab. He wants that drag to bring all the tiles the word needs.

## What Changes

- **The head off the word**: if a drag of the head ends away from the word, on an empty cell the word did not grow to,
  it leaves a copy of the head there and the head stays. If the player holds the head still for a moment first, the
  head itself moves, as with any placed letter. Growing (onto a free cell next to the head) and shrinking (back onto
  the cell before it) are unchanged.
- **Laying a word from its start**: pressing on a word's empty start cell and dragging puts the word's first letter on
  the start cell as soon as the finger moves. Then each free cell next to the head that the finger reaches gets the
  next letter, as when growing a word. A tap or double tap on the start cell works as before.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `word-snakes`: "Moving a head" becomes "The head off the word", and "Laying a word from its start" is added.

## First principles touched
- One rule for every placed letter: quick drag copies, hold and drag moves.
- A word is spelled in one gesture, from its start.

## Impact
- `src/parloku.nim`: the snake handler (`snakeStart`, `snakeCopy`, `snakeLoose`).
