## Solver checks: every puzzle in data/ has exactly one solution, equal to its answer key,
## and the pencil marks of a solved puzzle are its letters. Run: nim r -d:release tests/test_solver.nim
import std/[json, os, unittest]
import ../src/solver

proc load(f: string): (Problem, Grid) =
  let j = parseFile(f)
  let p = j["problem"]
  var pr: Problem
  for i, l in p["letters"].getElems: pr.letters[i] = l.getStr[0]
  for h in p["letterHints"]:
    pr.letterHints.add HintLetter(pos: (h["pos"][0].getInt, h["pos"][1].getInt), letter: h["letter"].getStr[0])
  for h in p["wordHints"]:
    pr.wordHints.add HintWord(pos: (h["pos"][0].getInt, h["pos"][1].getInt), word: h["word"].getStr)
  var key: Grid
  for r, row in j["solution"].getElems:
    for c, ch in row.getElems: key[r][c] = ch.getStr[0]
  (pr, key)

suite "solver":
  for f in walkFiles(currentSourcePath().parentDir.parentDir / "data" / "puzzle*.json"):
    test extractFilename(f):
      let (p, key) = load(f)
      check validate(p).len == 0
      let r = solve(p, defaultOptions(limit = 2, keep = 2))
      check r.count == 1
      check r.solutions[0] == key
      let cands = candidates(p)
      for row in 0 .. 5:
        for col in 0 .. 5: check cands[row][col] == @[key[row][col]]
  test "an empty problem has many solutions":
    var p: Problem
    for i, ch in "AILPST": p.letters[i] = ch
    check solve(p, defaultOptions(limit = 50, keep = 0)).count == 50
