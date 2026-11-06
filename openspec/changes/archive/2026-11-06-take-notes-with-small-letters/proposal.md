## Why

Pietro, 6 November 2026 (project thread "Add pencil-mark annotations to Parloku player"): he needs to take notes in
the player, the way sudoku players write small candidate digits in a cell. He chose the gesture and the names:

- A swipe down in an empty spot of the letters area below the board makes the letters small ("letterine"); a swipe
  up makes them big again ("letterone"). The grab area stays the same, with an outline of the big letter's size.
- With small letters, an empty cell can take several notes, and a note can be dragged from any other cell. The
  snake rules (growing and moving a word's head) don't apply to notes.

"Pencil" and "pen" fit paper, not a game of dragged tiles, so the specs say notes, small letters and big letters.
Notes first used the builder's look (grey pencil letters in a 3×2 grid). Pietro then asked (same day) for notes that
stay coloured tiles, at most four per cell, and for Snyder notation: a small letter between two cells.

Later the same day Pietro found that a vertical swipe scrolls the page inside an artifact on the phone, so the
switch became a double tap on an empty spot among the letters below the board.

## What Changes

- A double tap on an empty spot among the letters below the board switches between big letters and small letters.
  The six letters shrink, each keeping a thin outline of its big size, which is still where it is grabbed.
- With small letters, a letter dragged onto an empty cell writes itself there as a note, in its fixed spot of the
  cell. It can come from below, from any letter on the board (a given, a word's head) or from another
  note. It is always a copy: no tile moves, and no word grows or shrinks.
- A note is the letter's coloured tile, small (the size of the small letters below). A cell holds up to four notes,
  two by two in letter order. Writing a note that is already there changes nothing. Full cells take no notes.
- A letter dropped on the edge between two empty cells side by side writes a note on the edge (Snyder notation: it
  is in one of the two, and the edge shows the direction). Up to two notes per edge; hidden while either cell is full.
- With small letters, a double tap on a note rubs it out, and a double tap on an empty cell fills nothing. A double
  tap on a letter on the board sends it back as usual.
- With big letters, notes show but can't be touched. A letter dropped on a cell hides its notes, and they come back
  when the letter leaves. Notes are never rubbed out by the game on its own: that would be a hint.
- ↺ restart clears the notes. Notes and the size of the letters are saved with the progress.

## Capabilities

### New Capabilities
- `notes`: small letters and the notes they write.

### Modified Capabilities
- none (the snake and double-tap rules of `word-snakes` and `tiles-and-dragging` stay as they are with big letters)

## First principles touched
- One signal, one meaning: small letters below mean the next drag writes a note; nothing else changes size.
- Mistakes are cheap: a note is a copy, so writing one never moves a letter; a double tap rubs it out.
- Fit fingers: the small letters keep the big letters' grab area.

## Impact
- `src/parloku.nim`: `Board` gets `marks` and `small`; the view draws notes as items and shrinks the letters below;
  the drag engine removes items a state no longer draws; the double tap below the board, the note drop and the double tap on a note.
- `src/style.nim`: the small letters, their outlines, and the notes.
- `tools/specdrag.*`, `tools/specview.nim`: `small:`, `notes:`, `space` waypoint and `note A r3c3` in drag scenarios.
- Saved progress gains two fields (notes, letter size); older saves still load.
- `src/istruzioni.nim`: a "Letterine" gesture with a practice board.
- Built in PR #23, after PR #20 (game).
