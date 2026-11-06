## Writes the frozen runs of the devlog post "A puzzle, step by step" (src/devlog_steps.nim) with the step solver
## (src/stepsolver.nim):
##
##   nim r -d:release src/devlog_steps/stepsolver.nim data/puzzle3-PAROLE-PERLE-OPERA.json src/devlog_steps/parole.json
##
## The post reads the frozen output (parole.json, puzzles.json), so it does not change when the solver does.
import std/[json, os, strutils, sequtils, strformat]
import ../stepsolver

let j = parseFile(paramStr(1))
let p = j["problem"]
let letters = p["letters"].getElems.mapIt(it.getStr).join
var words: seq[string]
var starts: seq[int]
var givens: seq[(int, char)]
for h in p["wordHints"]:
  words.add h["word"].getStr
  starts.add h["pos"][0].getInt * 6 + h["pos"][1].getInt
for h in p["letterHints"]:
  givens.add (h["pos"][0].getInt * 6 + h["pos"][1].getInt, h["letter"].getStr[0])
let steps = explainSteps(letters, givens, words, starts)
var counts: seq[string]
for k in ["follow", "wordpaths", "hidden", "naked", "wordpoint", "pointing"]:
  counts.add &"{k}={steps.countIt(it.kind == k)}"
echo counts.join(" "), "  solved=", steps.solved
for s in steps: echo s.kind, ": ", s.text
var res = %*{"letters": letters, "words": words, "starts": starts, "givens": givens.mapIt(it[0]), "steps": []}
for s in steps:
  res["steps"].add %*{"kind": s.kind, "cell": s.cell, "letter": $s.letter, "text": s.text, "unit": s.unit,
    "word": s.word, "elims": s.elims.mapIt(it[0]), "board": s.board, "cands": s.cands}
writeFile(paramStr(2), $res)
