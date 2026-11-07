## 1. Decide

- [x] 1.1 Pietro describes the new gestures: move from the board, long press pins, copies from pins and finished words (7 Nov 2026)
- [ ] 1.2 Pietro reviews the scenarios in the spec viewer and tries the preview

## 2. Apply

- [x] 2.1 `Board.pins`: kept with the board, saved, undone by ↶; a pin goes when its letter leaves the board
- [x] 2.2 The stage: a press on a free placed letter waits; held still it toggles the pin, moved it drags (move or copy)
- [x] 2.3 `redirect`: copy from a given, a pinned letter or a finished word; move otherwise
- [x] 2.4 Dropping a moved letter below the board sends it home; elsewhere on the board it stays
- [x] 2.5 The snake head: a hold pins it, a drag off the word moves it (copies if pinned or a given)
- [x] 2.6 A finished word: its letters hop start to head, the head's eyes turn happy
- [x] 2.7 Help text in the game and on the istruzioni page
- [x] 2.8 specdrag: `long-press:`, `start pins:`, `end pins:`; `tests/gestures/pin.js`
- [x] 2.9 Run `nim r tools/specdrag.nim` and rebuild specs/ (src/specs_page.nim)
- [ ] 2.10 Archive the change before merging (its deltas replace scenarios in the specs that say "copy")
