## 1. Decide

- [x] 1.1 Pietro: two round undo and redo buttons with the menu, in the empty space at the top right (6 Nov 2026)

## 2. Apply

- [x] 2.1 ↶ and ↷ in `.undos`, shown with the menu (body.chrome), at the top right under the bar
- [x] 2.2 A redo list next to the undo history; a new move clears it; restart and its undo window keep both right
- [x] 2.3 `tests/gestures/undo.js`: undo twice, redo, a new move forgets the redo, the buttons go up with the menu
- [x] 2.4 Notes (PR #23) go through the same history, so ↶ and ↷ cover them
- [x] 2.5 Run `nim r tools/specdrag.nim` and rebuild specs/ (src/specs_page.nim)
