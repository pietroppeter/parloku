## Devlog post: adopting OpenSpec. Why Parloku now writes its behaviour down, what was set up, how a drag scenario is
## written and checked, what writing the specs turned up, and every spec and open change in the viewer.
## The "before" animation comes from src/devlog_openspec/before.json: the scenario run on main before PR #8, recorded by
## the first version of tools/specdrag.nim (which drove the drag engine natively; the snake gestures later moved to
## the browser wiring, so it now plays the built page instead).
import std/[json, os, strutils, strformat]
import nimib
import style
import ../tools/specview

let root = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = root / "devlog" / "openspec" / "index.html"
nb.doc.context["title"] = %"Parloku devlog · specs that play"
nb.doc.context["stylesheet"] = %(pageStyle & viewCss & """<style>
.kicker{font:700 .72rem/1.2 var(--font-body,sans-serif);letter-spacing:.12em;text-transform:uppercase;color:var(--muted);margin:1.6rem 0 .3rem}
.pair{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin:14px 0}
.pair .specview figure.drag{grid-template-columns:1fr;gap:6px}
.pair h4{font:700 15px var(--font-head);margin:0 0 4px}
.found{background:var(--card);border:1.5px solid var(--line);border-radius:14px;padding:4px 16px;margin:10px 0}
.found h4{font:700 16.5px var(--font-head);margin:10px 0 2px}
.found p{margin:4px 0 10px;font-size:15.5px}
.ask{border-left:4px solid var(--w0,#c01c3a);padding:4px 12px;background:var(--card);border-radius:0 12px 12px 0;margin:10px 0}
pre{overflow-x:auto;font-size:12.5px;line-height:1.45}
</style>""")
nb.doc.context["highlight"] = %""
nb.doc.context["disableHighlightJs"] = %true
func pageHeader(blk: JsonNode, nb: Nb): string =
  """<header><span><a href="../../">parloku</a> · devlog</span><span>05 Nov 2026</span></header>"""
nb.backend.partials["header"] = pageHeader

# ---- the scenarios, run on the game as it is now, plus the "before" run kept from main before PR #8
let (frames, run) = runScenarios(root, getEnv("PARLOKU_PAGE", "index.html"))
let before = parseFile(root / "src" / "devlog_openspec" / "before.json")
block:   # append the before scenarios to the frames, with their strings moved after the current ones
  let off = frames["strings"].len
  for s in before["strings"]: frames["strings"].add s
  for s in before["scenarios"]:
    for k, v in s["tiles"].pairs: s["tiles"][k] = %(v.getInt + off)
    for b in s["boards"]:
      b["bg"] = %(b["bg"].getInt + off)
      b["top"] = %(b["top"].getInt + off)
    frames["scenarios"].add s
let report = loadReport(root, frames)
proc findScen(name: string, fromBefore: bool): int =
  let n = frames["scenarios"].len
  let first = n - before["scenarios"].len
  for k in (if fromBefore: first else: 0) ..< (if fromBefore: n else: first):
    if frames["scenarios"][k]["scenario"].getStr == name and frames["scenarios"][k]["change"].getStr == "": return k
  -1

nbRawHtml: svgDefs & """<script>document.body.dataset.skin = localStorage.getItem('parloku:look') || 'niki'</script>
<p class="kicker">DEVLOG · OPENSPEC</p>
<h1>Specs that play</h1>
<p class="lede">The playtest of puzzle 2 found four things wrong with the word snakes. Before fixing more, we write down
how Parloku should behave, and make the gameplay parts of it run.</p>"""

nbText: """
Parloku's rules and gestures were spread across PR descriptions, devlog posts, code comments and chat. Each fix
was right on its own, and nothing stopped the next fix from undoing it. Pietro asked for one place where the
behaviour is written down, kept up to date and checked. That place is [OpenSpec](https://github.com/Fission-AI/OpenSpec),
set up the way [nanuq](https://github.com/pietroppeter/nanuq) uses it, and adapted to a game.

This post is the adoption, for Pietro to check. It shows what was set up, how a gameplay scenario becomes a small
animation that is also a test, what writing the specs turned up, and at the end every spec and every open change.
"""

nbRawHtml: """<h2><span class="num">01 · THE IDEA</span>Specs say what is, changes say what's next</h2>"""

nbText: """
OpenSpec keeps two kinds of files in `openspec/`:

- A **spec** (`openspec/specs/<capability>/spec.md`) says how one part of Parloku behaves *today*. It is a list of
  requirements ("dragging a head SHALL move it, never copy it"), each with scenarios: WHEN this happens, THEN that.
- A **change** (`openspec/changes/<name>/`) proposes new behaviour: a proposal (why and what), spec deltas (ADDED,
  MODIFIED or REMOVED requirements), and tasks. When the change ships it is *archived*, and its deltas are merged into
  the specs.

So the specs are always the truth about the game, and the open changes are the plan. Work goes
propose → build → archive, with the `/opsx:propose`, `/opsx:apply` and `/opsx:archive` commands that
`openspec init` installed for Claude in `.claude/`.
"""

nbRawHtml: """<h2><span class="num">02 · WHAT WAS SET UP</span>Twelve specs in five families</h2>"""

nbText: """
The specs follow the topics we went through together, grouped the way they are used:

| family | specs | what they cover |
|---|---|---|
| The puzzle | `game-rules`, `puzzle-format` | sudoku in six letters, words step by step, givens, one solution, word sets; JSON files and `?p=` codes |
| Playing | `tiles-and-dragging`, `word-snakes`, `player`, `logical-path` | stacks that divide, drops, copies and moves, double taps; outlines and the head gestures; the page around the board; the tutorial's method |
| Looking | `first-principles`, `play-screen`, `theming` | the ten design steps from "Back to basics"; the screen piece by piece; skins |
| Making | `solver`, `builder` | build-time checks and counting; the builder page |
| Working | `way-of-working` | explainers, devlog and garden, previews first, specs and scenarios |

Next to them:

- `openspec/config.yaml` tells OpenSpec (and Claude) the project's rules: proposals name the PR and the thread they
  come from, gameplay scenarios are written as drag blocks, a playtest finding becomes a scenario before it is fixed,
  and archiving a change adds its devlog line.
- `tools/specdrag.nim` runs the drag scenarios against the game's code (next section).
- `tools/specview.nim` draws specs and changes in the game's look; [`specs/`](../../specs/) is the living page, rebuilt
  with the game.
- `AGENTS.md` (and `CLAUDE.md`, which points to it) has the short list of working rules for anyone, person or agent,
  changing the repository.
"""

nbRawHtml: """<h2><span class="num">03 · SCENARIOS THAT PLAY</span>A board, a gesture, a board</h2>"""

nbText: """
Most scenarios are sentences. The gameplay ones can be more: a start board, a gesture and what the board must look
like after it. They are written in a `drag` block right under the scenario, like this one from `word-snakes`:
"""

block:   # the example, read from the spec itself so it can't drift
  let lines = readFile(root / "openspec" / "specs" / "word-snakes" / "spec.md").splitLines
  var a = 0
  while not lines[a].startsWith("#### Scenario: A misplaced last letter"): inc a
  var b = a
  while lines[b].strip != "```drag": inc b
  inc b
  while lines[b].strip != "```": inc b
  nbRawHtml: "<pre><code>" & lines[a .. b].join("\n").multiReplace(("&", "&amp;"), ("<", "&lt;")) & "</code></pre>"

nbText: """
`drag:` pulls straight away, `hold:` holds first (to move a letter), and a waypoint is a cell, `stack A` or `off`.
`outline` checks the cells a word's outline covers, and `grab: refused` says nothing may be picked up.

`nim r tools/specdrag.nim` plays every scenario on the built game page, in headless Chromium on an iPhone 13, the
way `tests/gestures/` already did for the snake fixes. It hands the start board to the page as saved progress, does
the gesture with real pointer events, and reads the end board and each word's outline back from what the page draws.
So it checks what a player gets, whichever part of the code does it (the declarative drag spec, or the snake gestures
that are written by hand in the browser wiring). Nothing in the game had to change for it. Every frame is recorded,
and the viewer replays it with the page's own drawing of tiles and outlines: the animation is not an illustration,
it is what the game did.

Here is Pietro's first playtest case, run on `main` as it was before PR #8, and on the game now:
"""

block:
  let a = findScen("A misplaced last letter", true)
  let b = findScen("A misplaced last letter", false)
  var html = """<div class="pair">"""
  if a >= 0: html.add """<div><h4>main, before PR #8</h4><div class="specview">""" & report.dragFigure(a) & "</div></div>"
  if b >= 0: html.add """<div><h4>the game now</h4><div class="specview">""" & report.dragFigure(b) & "</div></div>"
  html.add "</div>"
  nbRawHtml: html

nbText: """
Before, the A is copied, exactly as in the screenshot from the playtest. Now it moves. The scenario stays in the spec,
so the day a change copies it again, `tools/specdrag.nim` fails and says which scenario broke, with both boards.

Scenarios in the specs must pass. Scenarios in an open change may fail ("to do") until the change is built. The
whole loop has already run once: going on with a snake without lifting the finger, and backing a snake up, started as
the change `drag-a-snake-in-one-go` with failing scenarios. PR #8 made them pass, and `openspec archive` merged them
into `word-snakes`. The builder went the same way (`add-builder`, archived when PR #6 merged), and the double tap that
sends a whole snake back (PR #10) went straight into the specs.

**Where zogyn fits.** The game still carries its own copy of the drag engine that [zogyn](https://github.com/pietroppeter/zogyn)
packages. The day the game imports zogyn, each scenario in the viewer can become a small zogyn stage you drag
yourself, starting from the scenario's board, and the declarative part of the gestures can be checked natively with
zogyn's `dragTo`, in milliseconds instead of a browser run. I left that for a later change, so this one doesn't touch
the game.
"""

nbRawHtml: """<h2><span class="num">04 · WHAT WRITING THEM TURNED UP</span>Four things to look at</h2>"""

nbRawHtml: """<div class="found">
<h4>1 · Words and their own cells</h4>
<p>The outlines never use a cell twice (since PR #8). The game's solver lets a word step back onto its own cells.
The builder's solver forbids it, also forbids two words on one cell "for now", and has an optional "no U-turn" filter.
A puzzle could be unique for the builder and not for the game. That is a rule of the puzzle, so it is your call:
the change <code>settle-word-overlaps</code> lists the three questions.</p>
<h4>2 · Reset doesn't ask any more</h4>
<p>"Back to basics" made ↺ reset ask "sure?" before wiping the board. The game now restarts right away, and undo can't
bring the board back after a reset. The <code>first-principles</code> spec keeps the rule (mistakes are cheap: the one
action that wipes the board is undoable or asks first), so either reset gets undo or the rule changes.
<b>Decided:</b> reset gets undo. For 8 seconds after a reset (or until the first move) the button reads "annullo
rifaccio". That is the open change <code>rework-player-menu</code> (PR #13), with the new three-button menu.</p>
<h4>3 · Givens give copies</h4>
<p>A given can't be moved or sent back, but a drag on it, quick or after holding, pulls a copy of its letter, like any letter on the
board. I wrote that down as it is; say if givens should give nothing.</p>
<h4>4 · Two kinds of gesture tests</h4>
<p><code>tests/gestures/*.js</code> (from PR #8 and #10) check the snake cases with console output you read by eye.
The same cases are now drag scenarios that pass or fail on their own. I'd keep <code>tests/gestures</code> for now and
retire it once you trust the specs.</p>
</div>"""

nbRawHtml: """<h2><span class="num">05 · HOW WE WORK FROM NOW</span>Five habits</h2>"""

nbText: """
1. **A playtest finding becomes a scenario first.** It fails, then the fix makes it pass. That is how the four snake
   cases went in.
2. **New work starts as a change.** `/opsx:propose` writes the proposal, the spec deltas and the tasks; the PR builds
   it; `/opsx:archive` merges the deltas into the specs and adds the devlog line.
3. **Previews first, one clean PR.** Unchanged: you see an artifact on your phone before anything merges, nothing goes
   to `main` without your go, and old branches stay.
4. **Devlog and garden.** The devlog tells what shipped and why, dated. The garden grows ideas that may never ship,
   like the dividing tiles. An idea leaves the garden for the game through a change. (My reading, to confirm: see
   below.)
5. **Specs in English, short and plain**, like the devlog. Each says SHALL for what must hold and SHOULD for what is
   preferred.
"""

nbRawHtml: """<div class="ask"><b>For Pietro to check</b><ul>
<li>The five families and twelve names: do they match how you think about Parloku?</li>
<li>Devlog and garden: is my reading right?</li>
<li>Words and their own cells (<code>settle-word-overlaps</code>).</li>
<li>Givens giving copies, and retiring <code>tests/gestures</code> later.</li>
</ul></div>"""

nbRawHtml: """<h2><span class="num">06 · THE SPECS</span>All of them, as they are</h2>""" & summary(report)
nbRawHtml: renderSpecs(report)
nbRawHtml: """<h2><span class="num">07 · OPEN CHANGES</span>What's next</h2>""" & renderChanges(report)
nbRawHtml: "<details class=\"spoiler\"><summary>the scenario run, as printed by tools/specdrag.nim</summary><pre>" &
  run.multiReplace(("&", "&amp;"), ("<", "&lt;")) & "</pre></details>" & playerJs(report)
nbSave
