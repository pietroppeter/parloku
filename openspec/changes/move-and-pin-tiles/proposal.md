## Why

Pietro, 7 November 2026 (project thread "Plan Parloku releases and dev branch"), after watching Emilia playtest 0.2:
she often lets go of a tile a moment too early, and then, when she drags it to where she meant it to go, the game
pulls out a copy instead of moving it. Copying from the board is the odd gesture: what a finger expects from a tile on
a table is that it moves. Copies are still handy, so they should come from places the player chooses on purpose.

## What Changes

- **A letter on the board moves.** Dragging it puts it on the empty cell where it is let go. Let go elsewhere on the
  board it stays in its cell, and let go below the board it goes back to its letter.
- **📌 pins.** Holding a letter still for about half a second pins it: the builder's pin shows on its corner and the
  phone buzzes. A pinned letter stays where it is and dragging it pulls out a copy. Holding it again takes the pin off.
  If the finger moves on once the pin shows, the same gesture already drags a copy.
- **Copies come from four places only:** the letters below the board, a given (a given is pinned from the start, so
  it shows no pin), a pinned letter, and any letter of a finished word.
- **A finished word celebrates.** When a word's outline covers all its letters, its letters hop one after the other
  from start to head, and the head's eyes turn happy (^ ^) for as long as the word stays finished. The word that
  solves the puzzle gets the win party instead.
- **The head of an unfinished word** still grows and shrinks as before. A drag that ends away from the word now moves
  the head (it used to copy it), unless the head is pinned or a given.
- Dropped for now: a mark on the last tile of a letter left below. It may come back later, as one of some optional aids.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `tiles-and-dragging`: placed letters move; givens are copy sources; pinning a letter is added.
- `word-snakes`: a head off the word moves unless pinned; a finished word celebrates and is a copy source.

## First principles touched
- Mistakes are cheap: a tile let go too early is fixed by dragging it again.
- One signal, one meaning: the pin means "copies come from here"; a finished word's happy eyes mean the same for a word.
- Every action gets an answer: the pin shows (and the phone buzzes) while the finger is still down, and a finished word
  hops.

## Impact
- `src/parloku.nim`: `Board` gets `pins`, the stage's press handling (a hold pins, no more hold-to-move), `redirect`
  (which grabs copy), the snake handler, the overlay (happy eyes), the word hop, saving pins.
- `src/style.nim`: the pin mark on a tile.
- `src/istruzioni.nim` and the game's help text: moving, pinning, copying from a finished word.
- `tools/specdrag.nim`, `tools/specdrag.js`: a `long-press:` gesture and `start pins:` / `end pins:` lines.
- `tests/gestures/pin.js`.
- Built in the PR from branch `claude/project-thread-yvgsyl`; meant for 0.3 (Pietro picks the number).
