## Devlog post: a puzzle, step by step. The first explanation of a whole puzzle written by a program: every move
## with its reason, shown as a gallery of boards. Writes devlog/steps/index.html.
## The moves are a frozen run of src/devlog_steps/stepsolver.nim on puzzle 3 (parole.json, 6 Nov 2026), and the
## table is a frozen run on puzzles 1 to 7 (puzzles.json), so the post doesn't change with later puzzles or solvers.
import std/[json, os, strutils, strformat, sequtils]
import nimib
import style, stepsolver, stepsview

let root = currentSourcePath().parentDir.parentDir
let run = parseFile(root / "src" / "devlog_steps" / "parole.json")
let table = parseFile(root / "src" / "devlog_steps" / "puzzles.json")

const devlogStyle = """
<style>
.kicker{font:700 .72rem/1.2 var(--font-body,sans-serif);letter-spacing:.12em;text-transform:uppercase;color:var(--muted);margin:1.6rem 0 .3rem}
.tablewrap{overflow-x:auto}
table.ba{border-collapse:collapse;font-size:.8rem;width:100%;line-height:1.3}
table.ba small{color:var(--muted)}
table.ba th,table.ba td{padding:.4rem .3rem;border-bottom:1px solid var(--line);text-align:left;vertical-align:top}
table.ba td.n{text-align:right;font-family:"JetBrains Mono",monospace;white-space:nowrap}
.ask{background:var(--card);border:1.5px solid var(--line);border-radius:14px;padding:6px 18px}
</style>
"""

nbInit
nb.doc.filename = root / "devlog" / "steps" / "index.html"
nb.doc.context["title"] = %"Parloku devlog · a puzzle, step by step"
nb.doc.context["stylesheet"] = %(pageStyle & devlogStyle & "<style>" & galleryCss & "</style>")
nb.doc.context["highlight"] = %""
nb.doc.context["disableHighlightJs"] = %true
func pageHeader(blk: JsonNode, nb: Nb): string =
  """<header><span><a href="../../">parloku</a> · <a href="../">devlog</a></span><span>06 Nov 2026</span></header>"""
nb.backend.partials["header"] = pageHeader

# ---- the boards of the gallery, drawn at build time
proc fromJson(j: JsonNode): Explained =
  result = Explained(id: "gal", letters: j["letters"].getStr, words: j["words"].getElems.mapIt(it.getStr),
    starts: j["starts"].getElems.mapIt(it.getInt), givens: j["givens"].getElems.mapIt(it.getInt))
  for st in j["steps"].getElems:
    result.steps.add Step(kind: st["kind"].getStr, cell: st["cell"].getInt, letter: st["letter"].getStr[0],
      text: st["text"].getStr, unit: st["unit"].getElems.mapIt(it.getInt), word: st["word"].getInt,
      elims: st["elims"].getElems.mapIt((it.getInt, ' ')), board: st["board"].getStr,
      cands: st["cands"].getElems.mapIt(it.getStr))
  result.solution = result.steps[^1].board
let parole = fromJson(run)

# ---- the post

nbRawHtml: """
<p class="kicker">DEVLOG · PUZZLES</p>
<h1>A puzzle, step by step</h1>
<p class="lede">The first explanation of a whole Parloku puzzle written by a program: every move, with its reason,
from the given letters to the last cell. It solves Pietro's PAROLE · PERLE · OPERA without a single guess.</p>
"""

nbRawHtml: """<h2><span class="num">01 · WHY</span>Unique is not enough</h2>"""

nbText: """
A puzzle in `data/` must have exactly one solution, and the build checks it. But one solution doesn't make a good
puzzle. A good one can be solved by looking, one sure move at a time, without trying a letter and backing out.
Pietro makes the puzzles by hand in the [builder](https://pietroppeter.github.io/parloku/builder.html) for exactly
this reason, and playtests the ones Claude proposes.

So we need to know whether a puzzle can be solved without guessing, and *how*. The solver in `src/solver.nim`
answers the first half: before it branches, it only makes safe deductions (it crosses out letters, fills a letter
that has one place left, and keeps the word paths that still fit). When it reaches the solution without ever
branching (one search node), the puzzle needs no guess. All seven puzzles in `data/` pass.
But the solver's deductions aren't written for people, and it doesn't say what it did.
"""

nbRawHtml: """<h2><span class="num">02 · THE MOVES</span>Only moves a person can check</h2>"""

nbText: """
The step solver (`src/devlog_steps/stepsolver.nim`) solves with a short list of moves, always trying them in this order:

1. **Follow the word** (*segui la parola*). The next letter of a word sits next to the previous one. When only one
   neighbour can still take it, it goes there. Sometimes two neighbours could, but from one of them the word can't
   be finished, or it would take cells another word needs (words never share a cell). The step then says which.
2. **Only place** (*unico posto*): in a row, column or box, a letter has one cell left.
3. **Only letter** (*unica lettera*), then **eliminations**: used only if nothing above works.

It starts like Pietro's method in the 🎓 tutorial: the given letters, then the first letter of every word, then
follow the words while the sudoku lets you. The tutorial does this one move at a time while you play, and it ignores the
other words' cells. This solver runs over the whole puzzle, keeps the pencil marks, and writes each move in Italian,
the game's language.
"""

nbRawHtml: """<h2><span class="num">03 · THE GALLERY</span>PAROLE · PERLE · OPERA in 33 steps</h2>"""

nbText: """
Swipe, or tap to go on (tap the left side to go back). r and c are row and column, from r1c1 at the top left. The
thick circle is the letter just placed; the shading shows the reason, a row, column or box or the word's path so
far. Each word has its container, as in the game: a ring on its start that grows around its letters. The small grey
letters are what each empty cell can still take.
"""

nbRawHtml: parole.gallery
nbRawHtml: """<p class="hint">← scorri o tocca →</p>"""

nbJsFromCode:
  import std/dom
  proc scrollByX(e: Element, dx: float) {.importjs: "#.scrollBy({left: #, behavior: 'smooth'})".}
  proc scrollToStart(e: Element) {.importjs: "#.scrollTo({left: 0, behavior: 'smooth'})".}
  proc left(e: Element): float {.importjs: "#.getBoundingClientRect().left".}
  proc width(e: Element): float {.importjs: "#.getBoundingClientRect().width".}
  proc clientX(e: Event): float {.importjs: "#.clientX".}
  proc scrollLeftF(e: Element): float {.importjs: "#.scrollLeft".}
  proc scrollWidthF(e: Element): float {.importjs: "#.scrollWidth".}
  let gal = document.getElementById("gal")
  gal.addEventListener("click", proc (ev: Event) =
    let step = gal.querySelector(".sl").width + 16
    if ev.clientX - gal.left < gal.width * 0.3: gal.scrollByX(-step)
    elif gal.scrollLeftF + gal.width >= gal.scrollWidthF - 4: gal.scrollToStart()
    else: gal.scrollByX(step))

nbRawHtml: """<h2><span class="num">04 · SEVEN PUZZLES</span>What the moves say</h2>"""

nbText: """
The same solver on the seven puzzles in `data/` today. "Look ahead" counts the follow moves where one neighbour had to be
ruled out by trying the rest of the word, the hardest moves in these puzzles.
"""

block:
  var rows = ""
  for r in table.getElems:
    let words = r["words"].getElems.mapIt(it.getStr).join(" ")
    rows.add &"""<tr><td>{r["puzzle"].getStr}</td><td>{words}<br><small>{r["author"].getStr}</small></td>""" &
      &"""<td class="n">{r["givens"].getInt}</td><td class="n">{r["follow"].getInt}</td><td class="n">{r["lookahead"].getInt}</td>""" &
      &"""<td class="n">{r["hidden"].getInt}</td><td class="n">{r["naked"].getInt + r["elims"].getInt}</td></tr>"""
  nbRawHtml: """<div class="tablewrap"><table class="ba"><tr><th>#</th><th>puzzle, by</th><th>givens</th>""" &
    """<th>follow</th><th>look ahead</th><th>only place</th><th>other</th></tr>""" & rows & "</table></div>"

nbText: """
They are very alike: eleven to thirteen follow moves, two to seven look-aheads (IMPARA · PRIMA · MATITA has the most, and Pietro found it the hardest), and the rest are "only place" moves.
None needs an only-letter move or an elimination. Puzzles 4 to 7, the first by Claude, start from one or two given letters and still never need a guess: the words carry them.
"""

nbRawHtml: """<div class="ask">"""
nbText: """
**What makes a puzzle well designed?** We don't know yet, and these numbers alone won't tell us. They are a start:
a puzzle that needs a guess is out, and a puzzle where the words do most of the work feels like Parloku and not like
plain sudoku. Next we'll playtest and see which steps feel good and which feel like chores.
"""
nbRawHtml: """</div>"""

nbSave
