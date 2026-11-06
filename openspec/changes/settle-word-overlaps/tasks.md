## 1. Decide

- [x] 1.1 Pietro picks the rule for reusing cells within a word: never (6 Nov 2026); across words and U-turns stay open

## 2. Apply

- [ ] 2.1 The game's solver uses the outlines' rule (`trace` without `revisit`)
- [x] 2.2 Same rule in the builder's `src/solver.nim` (already)
- [ ] 2.3 Re-check the puzzles in `data/`
- [ ] 2.4 Run `nim r tools/specdrag.nim` and rebuild specs/ (src/specs_page.nim)
