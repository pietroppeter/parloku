## 1. Decide

- [x] 1.1 Pietro: add author and creation date to the puzzle data; puzzles up to ESTATE are pietroppeter's, ESTATE is claude's (6 Nov 2026)

## 2. Apply

- [x] 2.1 `author` and `created` in every `data/puzzle*.json` (dates of puzzles 1 and 2 from puzzlepaw's history) (PR #24)
- [x] 2.2 Add puzzle 4, ESTATE · MARE · SERATA, and puzzle 5, MONTE · NEVE · VENTO, both by Claude (PR #24)
- [x] 2.3 `tests/test_solver.nim` checks both fields
- [ ] 2.4 Run `nim r tools/specdrag.nim` and rebuild specs/ (`src/specs_page.nim`)
