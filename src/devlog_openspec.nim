## Devlog post (6 Nov 2026): adopting OpenSpec. Why Parloku now writes its behaviour down, what was set up, how a drag
## scenario is written and checked, and what writing the specs turned up. A dated post: it tells the adoption as it
## happened and does not follow the specs as they change. The living specs are the spec page (src/specs_page.nim, specs/).
## Its two animations are frozen runs: src/devlog_openspec/before.json (main before PR #8, recorded by the first,
## native tools/specdrag.nim) and after.json (the game on 6 Nov 2026, from tools/specdrag.js).
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
  """<header><span><a href="../../">parloku</a> · <a href="../">devlog</a></span><span>06 Nov 2026</span></header>"""
nb.backend.partials["header"] = pageHeader

# ---- the two frozen runs of "A misplaced last letter": before PR #8, and the game on 6 Nov 2026
let before = parseFile(root / "src" / "devlog_openspec" / "before.json")
let after = parseFile(root / "src" / "devlog_openspec" / "after.json")
let frames = %*{"strings": [], "scenarios": []}
for part in [after, before]:   # the same layout as tools/specdrag.js writes: strings, then scenarios pointing into them
  let off = frames["strings"].len
  for t in part["strings"]: frames["strings"].add t
  for sc in part["scenarios"]:
    for k, v in sc["tiles"].pairs: sc["tiles"][k] = %(v.getInt + off)
    for bd in sc["boards"]:
      bd["bg"] = %(bd["bg"].getInt + off)
      bd["top"] = %(bd["top"].getInt + off)
    frames["scenarios"].add sc
let report = loadReport(root, frames)
proc findScen(name: string, fromBefore: bool): int =
  let n = frames["scenarios"].len
  let first = n - before["scenarios"].len
  for k in (if fromBefore: first else: 0) ..< (if fromBefore: n else: first):
    if frames["scenarios"][k]["scenario"].getStr == name: return k
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

This post tells the adoption as it happened, on 5 and 6 November 2026: what was set up, how a gameplay scenario
becomes a small animation that is also a test, and what writing the specs turned up. The specs keep changing after
it. For how Parloku behaves today, every spec and every open change with its scenarios played on the current game,
see the [spec page](../../specs/).
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

nbRawHtml: """<h2><span class="num">02 · WHAT WAS SET UP</span>Fourteen specs in six families</h2>"""

nbText: """
The specs follow the topics we went through together, grouped the way they are used:

| family | specs | what they cover |
|---|---|---|
| The puzzle | `game-rules`, `puzzle-format` | sudoku in six letters, words step by step, givens, one solution, word sets; JSON files and `?p=` codes |
| Looking | `first-principles`, `play-screen`, `theming` | the ten design steps from "Back to basics"; the screen piece by piece; skins |
| Playing | `tiles-and-dragging`, `word-snakes`, `player` | tiles that divide, drops, copies and moves, double taps; outlines and the head gestures; the menu and the page around the board |
| Telling | `how-to-play`, `languages`, `logical-path` | rules cards, istruzioni, first lesson and tutorial; English and Italian; the tutorial's method |
| Crafting | `solver`, `builder` | build-time checks and counting; the builder page |
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
`drag:` pulls straight away, `hold:` holds first (to move a letter), and a waypoint is a cell, `below A` (the letter's tile under the board) or `off`.
`outline` checks the cells a word's outline covers, and `grab: refused` says nothing may be picked up.

`nim r tools/specdrag.nim` plays every scenario on the built game page, in headless Chromium on an iPhone 13, the
way `tests/gestures/` already did for the snake fixes. It hands the start board to the page as saved progress, does
the gesture with real pointer events, and reads the end board and each word's outline back from what the page draws.
So it checks what a player gets, whichever part of the code does it (the declarative drag spec, or the snake gestures
that are written by hand in the browser wiring). Nothing in the game had to change for it. Every frame is recorded,
and the viewer replays it with the page's own drawing of tiles and outlines: the animation is not an illustration,
it is what the game did.

Here is Pietro's first playtest case, run on `main` as it was before PR #8, and on the game on 6 November:
"""

block:
  let a = findScen("A misplaced last letter", true)
  let b = findScen("A misplaced last letter", false)
  var html = """<div class="pair">"""
  if a >= 0: html.add """<div><h4>main, before PR #8</h4><div class="specview">""" & report.dragFigure(a) & "</div></div>"
  if b >= 0: html.add """<div><h4>the game on 6 Nov</h4><div class="specview">""" & report.dragFigure(b) & "</div></div>"
  html.add "</div>"
  nbRawHtml: html

nbText: """
Before, the A is copied, exactly as in the screenshot from the playtest. Now it moves. The scenario stays in the spec,
so the day a change copies it again, `tools/specdrag.nim` fails and says which scenario broke, with both boards.

Scenarios in the specs must pass. Scenarios in an open change may fail ("to do") until the change is built. The
whole loop has already run once: going on with a snake without lifting the finger, and backing a snake up, started as
the change `drag-a-snake-in-one-go` with failing scenarios. PR #8 made them pass, and `openspec archive` merged them
into `word-snakes`. The builder went the same way (`add-builder`, archived when PR #6 merged), and the double tap that
sends a whole snake back (PR #10) went straight into the specs. The player menu and the new board look of PR #13
were the change `rework-player-menu`, archived when #13 merged. The builder's alignment with the player (PRs #14 and #16)
is archived too. The open changes are `settle-word-overlaps` and `keep-one-look` (PR #15).

**Where zogyn fits.** The game still carries its own copy of the drag engine that [zogyn](https://github.com/pietroppeter/zogyn)
packages. The day the game imports zogyn, each scenario in the viewer can become a small zogyn stage you drag
yourself, starting from the scenario's board, and the declarative part of the gestures can be checked natively with
zogyn's `dragTo`, in milliseconds instead of a browser run. I left that for a later change, so this one doesn't touch
the game.
"""

nbRawHtml: """<h2><span class="num">04 · CHECKED AGAINST THE GAME</span>A second pass, on 6 November</h2>"""

nbText: """
Pietro was right that the first draft lagged behind the game. I went through every spec again, against the code on
`main` (after #13, #14 and #16), the open PRs (#15, #17, #18) and the page itself in a phone-sized browser. These were
wrong and are fixed now:

- **Tiles.** The specs still had six-tile *stacks*. The game has one tile per letter that divides: pulling it stretches
  a neck until the copy splits off, the letter ripples, a copy brought back merges, and an empty ring with ✓ shows when
  all six copies are down. `tiles-and-dragging` now says that, and the scenarios write `below A` instead of `stack A`.
- **Maiolica.** It is retired, not "kept available": `keep-one-look` now says so, with a task to take its CSS out.
- **Nothing below the game.** The specs said the rules cards, the skin switch and the code notebook sit below the play
  area. Since #13 the page shows only the game, and none of them is ever visible. `play-screen`, `player`,
  `how-to-play` and `first-principles` are corrected.
- **EN / IT and 🎓.** Neither has a button any more: the language comes from `?lang=`, the last choice or the
  browser, and the tutorial opens with `?tutorial` or from the first lesson. `languages` and `how-to-play` say so.
- **Builder.** #14 and #16 are merged, so `align-builder-with-player` is archived. The builder spec had a "count up to
  10+" and called one circle "ready". In fact the circles explore the grids with every placed letter (up to 100), and
  whether the puzzle itself has one solution is said when you tap 💾. It also gained word sets, unpinning, the no-U and
  one-way rules.
- **Smaller ones.** The solver stops at 100 in the builder, the daily splash shows no puzzle, the clue cells are
  marked (not numbered), and the README still described stacks.

New things the check turned up, and what Pietro decided:

- **The tutorial doesn't fit the screen.** With the coach box on top, the letters end at 806 px on an iPhone 13, past
  the 664 px that `first-principles` asks for. Pietro decided its messages go on semi-transparent white-ish blobs over
  the board, never on the cells, letter or clue of the step: the change `fit-tutorial-on-screen`.
- **The code notebook is invisible.** The game page is still the nimib explainer underneath, but nothing shows it
  now. Pietro decided it moves to a devlog post: that is the change `move-notebook-to-devlog`.
- **No way to switch language while playing.** Pietro decided Italian is the game's language for now, English is a
  draft, and there is no switch: the change `italian-first`. English stays the language of development (specs, code,
  PRs), which `way-of-working` now says.
"""

nbRawHtml: """<h2><span class="num">05 · WHAT WRITING THEM TURNED UP</span>Six things Pietro decided</h2>"""

nbRawHtml: """<div class="found">
<h4>1 · Words and their own cells: decided</h4>
<p>The outlines and the builder never let a word use a cell twice; the game's solver did. Pietro decided a word never
reuses its cells, so the change <code>settle-word-overlaps</code> now says that. What's left is the small code change
in the game's solver and a re-check of the puzzles, as its own PR. Whether two words may share a cell, and U-turns,
stay as they are for now.</p>
<h4>2 · Reset: decided and shipped</h4>
<p>Reset restarts at once and offers "annullo rifaccio" for 8 seconds. It came in with PR #13, so the change
<code>rework-player-menu</code> is archived: the menu, ancora!, the classic grid, the rolling conflicts and the thinner
outlines are all in the specs now.</p>
<h4>3 · Undo, hint and link hidden while playing: on purpose</h4>
<p>Since #13 the menu has only istruzioni, ancora! and rifaccio. Pietro confirmed that hiding ↶ undo, 💡 hint and 🔗 link
is on purpose, so <code>player</code> now says so, and <code>first-principles</code> says a move is taken back with the
same gestures that made it (and a reset with "annullo rifaccio").</p>
<h4>4 · istruzioni in Italian only, for now</h4>
<p>The <code>languages</code> spec says every text a player reads exists in English and Italian, except istruzioni,
which stays Italian for now, as Pietro said.</p>
<h4>5 · Givens give copies: confirmed</h4>
<p>A given can't be moved or sent back, but a drag on it, quick or after holding, pulls a copy of its letter, like any
letter on the board. Pietro confirmed it, so <code>tiles-and-dragging</code> stays as it is.</p>
<h4>6 · Two kinds of gesture tests: settled</h4>
<p><code>tests/gestures/*.js</code> checked the snake and menu cases with console output read by eye. The snake
cases are drag scenarios now, so <code>snake.js</code>, <code>gioco.js</code> and <code>unsnake.js</code> are gone, and CI
plays the scenarios on every push: a failing one turns the build red. <code>menu.js</code> and <code>switch.js</code> stay,
because they check taps and animations a drag scenario can't describe.</p>
</div>"""

nbRawHtml: """<h2><span class="num">06 · HOW WE WORK FROM NOW</span>Five habits</h2>"""

nbText: """
1. **A playtest finding becomes a scenario first.** It fails, then the fix makes it pass. That is how the four snake
   cases went in.
2. **New work starts as a change.** `/opsx:propose` writes the proposal, the spec deltas and the tasks; the PR builds
   it; `/opsx:archive` merges the deltas into the specs and adds the devlog line.
3. **Previews first, one clean PR.** Unchanged: Pietro sees an artifact on the phone before anything merges, nothing goes
   to `main` without Pietro's go, and old branches stay.
4. **Devlog and garden.** The devlog is dated posts, each about one step in how the game evolves. The digital
   garden (after Maggie Appleton) is articles that stand apart from the posts: published before they are complete,
   then come back to and grown. How the garden works is still taking shape, and the `way-of-working` spec says so.
5. **Specs in English, short and plain**, like the devlog. Each says SHALL for what must hold and SHOULD for what is
   preferred.
"""

nbRawHtml: """<h2><span class="num">07 · FROM HERE</span>The specs live on their own page</h2>"""

nbText: """
This post stays as it is. The specs and the changes go on in `openspec/`, and the [spec page](../../specs/) shows
them as they are now: CI rebuilds it on every push and plays each drag scenario on the game being built, so the page
is never older than the game. Its link is in the README, next to the game and the builder.
"""
nbRawHtml: playerJs(report)
nbSave
