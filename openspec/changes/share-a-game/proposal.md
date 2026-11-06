## Why

Pietro, 6 November 2026 (project thread "Design spoiler-free emoji sharing", ahead of the 0.2 playtest release): after
a win, the player should be able to share how the game went, like Wordle, with emoji that show someone played but
spoil nothing, and that say something to whoever has played the same puzzle. His idea: coloured balls for the snakes
in the order they were made, and a ball of another colour for every other move. He picked the details from a preview
of three options (https://claude.ai/artifact/EbTVtdzeQDBhNxw9f64Utq): one ball per letter, in the word's colour for
every letter of a snake, ⚫ for a letter sent back, and after 48 moves "…" with the count. From the celebration thread:
🥳 and the emoji of the dance the player saw. He also asked for istruzioni to explain the share, with a table of
contents, and the gestures as a gallery you swipe through, to save vertical space.

## What Changes

- The game keeps a log of moves: every letter put on the board, and every letter sent back below (by a double tap, by
  ↶ undo, by a snake stepping back), is one move. Moving a snake's head is one move. The log is saved with the board,
  with the dance of the win, so a reload shares the same text. Notes (letterine) are not moves.
- The Evviva! banner and the share both count these moves.
- Under Evviva! 🥳 a **📤 condividi** button opens the phone's share sheet (or copies the text elsewhere):
  `Parloku 1 🥳🐍 · 37 mosse · 5:55`, then the balls six to a line, then a short link `…/parloku/?p=1`.
- Balls: 🔴 🟢 🔵 (the clue colours, in clue order) for every letter of a word on the solved board, counted on the move
  that put it there for the last time; ⚫ for a letter sent back; ⚪ for every other move. A game longer than 48 moves
  shows its first seven lines, then `… +N`. ⭐ when the moves are as many as the empty cells (no letter moved twice).
- Dances: 🌊 ripples, 🐍 snakes, 🪀 letters.
- `?p=N` opens the N-th puzzle of the menu, so the link in the share is short.
- istruzioni: a table of contents (rules, gestures, sharing), the gestures in a horizontal gallery, and a section on
  sharing with an example.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `player`: sharing a solved game; a puzzle by its number.
- `how-to-play`: the istruzioni page has a table of contents, a gesture gallery and a sharing section.

## First principles touched
- none: the share shows only after a win, below the solved board.

## Impact
- `src/parloku.nim`: `moveLog`, `logMoves`, `shareText`, the share button in `bannerHtml`, `?p=N`, the saved board.
- `src/style.nim`: the banner with the share button. `src/istruzioni.nim`: TOC, `.gallery`, the sharing section.
- `tests/gestures/share.js`: a clean game, an undo, a long game, a reload.
- Built in the PR from branch `claude/project-thread-2yjrn4`.
