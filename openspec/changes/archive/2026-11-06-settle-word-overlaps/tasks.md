## 1. Decide

- [x] 1.1 Pietro picks the rule for reusing cells within a word: never (6 Nov 2026)
- [x] 1.2 Pietro picks the rule for two words on one cell: never, and an outline never takes another word's letters
  by itself (6 Nov 2026, after OPERA ran over PERLE's P); U-turns stay open

## 2. Apply (PR #20)

- [x] 2.1 The game's solver uses the outlines' rule (`trace` without `revisit`)
- [x] 2.2 Same rule in `src/solver.nim` (`defaultOptions` forbids reuse and sharing) and in the builder's copy
- [x] 2.3 Outlines never overlap (`outlines`), and a snake never steps onto another word's start cell
- [x] 2.4 Re-check the puzzles in `data/` (both still unique; `tests/test_solver.nim`)
- [x] 2.5 Run `nim r tools/specdrag.nim` and rebuild specs/ (src/specs_page.nim)
