## Garden devlog post: tiles that divide like cells.
## Grab a round tile and a copy buds off it; near a place it can go, the copy splits away; bring it back and it
## rejoins. Dragging is zogyn (declarative: we only list the states a drag can reach); the membrane is drawn
## on top by a small effect layer that reads where things are on screen.
## Build from the repo root: sh src/deps.sh && nim c -r -d:release src/garden_cells.nim  (writes garden/cells/index.html)
import std/[os, json]
# nbJsFromCode compiles its JavaScript in the current directory: work in src/, whose config.nims puts zogyn on the path
setCurrentDir(currentSourcePath().parentDir)
import nimib
import zogyn/nbstage

const gardenStyle = """
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,600;0,9..144,800;1,9..144,600&family=Karla:wght@400;700&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
<style>
:root{--paper:#f2f0e1;--card:#fbfaf2;--ink:#24361f;--muted:#66705a;--line:#d9d6bf;--leaf:#4f7f35;--moss:#a7c27a;--bloom:#d9577a}
*{box-sizing:border-box}
[hidden]{display:none!important}
:root{padding:env(safe-area-inset-top,0) env(safe-area-inset-right,0) env(safe-area-inset-bottom,0) env(safe-area-inset-left,0)}
html{background:var(--paper)}
body{margin:0 auto;max-width:740px;padding:0 16px 60px;color:var(--ink);font:17px/1.62 Karla,system-ui,sans-serif;background:var(--paper)}
body::before{content:"";display:block;height:22px;margin:0 -16px;border-bottom:2px solid var(--ink);
  background:radial-gradient(circle at 11px 11px,var(--moss) 0 6px,transparent 7px) 0 0/44px 22px,
             radial-gradient(circle at 33px 11px,var(--bloom) 0 4px,transparent 5px) 0 0/44px 22px,#e4e8c9}
header,footer .nb-box{display:flex;justify-content:space-between;gap:10px;flex-wrap:wrap;font:13px "JetBrains Mono",monospace;color:var(--muted);padding:12px 0}
header{border-bottom:1px solid var(--line)} footer .nb-box{border-top:1px solid var(--line);margin-top:40px}
header a,footer a{color:var(--muted)}
h1,h2,h3{font-family:Fraunces,Georgia,serif;line-height:1.08;letter-spacing:-.01em}
h1{font-size:clamp(38px,9vw,64px);font-weight:800;margin:24px 0 6px}
h1 i{color:var(--leaf)}
h2{font-size:28px;font-weight:800;margin:50px 0 10px;padding-top:16px;border-top:2px solid var(--ink)}
h2 .num{display:block;font:600 12.5px "JetBrains Mono",monospace;letter-spacing:.12em;color:var(--bloom);margin-bottom:6px}
h3{font-size:21px;margin:30px 0 6px}
a{color:var(--leaf);text-underline-offset:3px}
.kicker{font:700 12px "JetBrains Mono",monospace;letter-spacing:.14em;color:var(--leaf);margin:28px 0 0}
.lede{font:italic 600 20px/1.45 Fraunces,Georgia,serif;color:#3b4d33;margin-top:4px}
p code,li code,td code{font:14px "JetBrains Mono",monospace;background:#e6e4cc;padding:1px 5px;border-radius:4px;overflow-wrap:anywhere}
pre{margin:14px 0;overflow-x:auto;border-radius:12px}
pre code{display:block;padding:14px 16px;font:12.8px/1.55 "JetBrains Mono",monospace;background:var(--card);border:1px solid var(--line);border-radius:12px;color:#22301d}
pre.nb-output,pre samp{display:block;padding:12px 16px;font:12.8px/1.5 "JetBrains Mono",monospace;background:var(--ink);color:#eef0dc;border-radius:12px;white-space:pre;overflow-x:auto}
details{margin:14px 0;border:1px dashed #b9b591;border-radius:12px;padding:4px 12px;background:var(--card)}
details summary{cursor:pointer;font:13px "JetBrains Mono",monospace;color:var(--muted);padding:6px 0}
table{border-collapse:collapse;font-size:15px;width:100%} td,th{padding:6px 8px;border-bottom:1px solid var(--line);text-align:left;vertical-align:top}
.zogyn-stage{--zg-ink:var(--ink);--zg-card:var(--card);--zg-muted:var(--muted);--zg-hot:var(--bloom);border-radius:22px;box-shadow:5px 5px 0 var(--ink);max-width:440px;margin-left:auto;margin-right:auto}
.zogyn-stage .item{transition:transform .38s cubic-bezier(.2,.9,.25,1.15)}
.zogyn-stage .item.lifted{filter:none}
.zogyn-stage .ghost-toggle{bottom:6px}
.strip text,.zogyn-stage text{font-family:Fraunces,Georgia,serif;font-weight:800;pointer-events:none}
.membrane{pointer-events:none}
.controls{display:flex;flex-wrap:wrap;align-items:center;justify-content:center;gap:8px;margin:12px 0 4px;font:13px "JetBrains Mono",monospace;color:var(--muted)}
.btn{font:700 13px "JetBrains Mono",monospace;border:2px solid var(--ink);background:var(--card);color:var(--ink);border-radius:999px;padding:5px 13px;cursor:pointer;box-shadow:2px 2px 0 var(--ink)}
.btn.on{background:var(--ink);color:var(--card)}
.btn:active{transform:translate(2px,2px);box-shadow:none}
.status{text-align:center;font:italic 600 16px Fraunces,Georgia,serif;color:var(--muted);min-height:1.6em;margin:4px 0 0}
.strip{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:8px;margin:16px 0}
@media (min-width:620px){.strip{grid-template-columns:repeat(6,minmax(0,1fr))}}
.strip figure{margin:0;background:var(--card);border:1.5px solid var(--line);border-radius:12px;padding:4px}
.strip svg{display:block;width:100%;height:auto}
.strip figcaption{text-align:center;font:12px "JetBrains Mono",monospace;color:var(--muted)}
.note{background:var(--card);border-left:4px solid var(--moss);border-radius:0 12px 12px 0;padding:8px 14px;margin:16px 0}
</style>
"""

nbInit
nb.doc.filename = currentSourcePath().parentDir.parentDir / "garden" / "cells" / "index.html"
nb.doc.context["title"] = %"Parloku garden · tiles that divide like cells"
nb.doc.context["stylesheet"] = %gardenStyle
nb.doc.context["highlight"] = %""
nb.doc.context["disableHighlightJs"] = %true
func pageHeader(blk: JsonNode, nb: Nb): string =
  """<header><span><a href="../../">parloku</a> · garden devlog</span><span>05 Nov 2026</span></header>"""
nb.backend.partials["header"] = pageHeader
nbZogynStyle()

nbRawHtml: """
<p class="kicker">GARDEN DEVLOG · 01</p>
<h1>Tiles that <i>divide</i> like cells</h1>
<p class="lede">In the first Parloku every letter came as a stack of six tiles. Here we try something else:
a tile is a cell, and you pull a new one out of it. Pull a little and a bud swells. Get near a place it may go
and the bud splits away. Come back and it joins again.</p>
"""

nbRawHtml: """<h2><span class="num">01 · TRY IT</span>A garden of three cells</h2>"""

nbText: """
Drag **S** or **O** towards one of the empty rings. Watch the neck thin as you go, snap as you reach a ring,
and grow back if you return. Let go anywhere else and the bud is pulled home.

Each letter may be used **twice**. **L** already has both of its copies out, so tug it: it stretches and
won't let go. Every tile in the garden is a cell, so the ones you planted can bud as well.
"""

nbRawHtml: """
<div class="zogyn-stage" id="garden"></div>
<div class="controls">places: <button class="btn" data-n="1">1</button><button class="btn" data-n="3">3</button>
<button class="btn on" data-n="5">5</button><button class="btn" data-n="8">8</button>
<button class="btn" id="garden-reset">reset</button></div>
<p class="status" id="garden-status"></p>
"""

nbText: """
The number of places is free: the drag lists every ring the copy may land on, and there can be one or many.
Tick *show machinery* to see them: each coral dot is a place the copy could go, plus one for home.
"""

nbRawHtml: """<h2><span class="num">02 · ON THE BOARD</span>The same cells in a mini sudoku</h2>"""

nbText: """
Here the places come from a rule instead of a list. A letter may go into an empty cell only if its row, its
column and its 2×3 box don't have it yet. The six letters below the board are sources, and so is every tile on it.
Once a letter has no legal cell left (all six are placed, or the rows and boxes block it), it won't come loose.
These are the three given letters of puzzle 1 (ITALIA, PASTA, ALPI). Here only the sudoku rule applies, not the words.
"""

nbRawHtml: """
<div class="zogyn-stage" id="board"></div>
<div class="controls"><button class="btn" id="board-reset">reset</button></div>
<p class="status" id="board-status"></p>
"""

nbRawHtml: """<h2><span class="num">03 · HOW IT WORKS</span>Two layers that don't talk much</h2>"""

nbText: """
The effect has two independent halves:

1. **Where can the copy go?** That's a question about the *model*, and [zogyn](https://github.com/pietroppeter/zogyn)
   answers it. We never write a drop handler. For the grabbed tile we list the states the drag can reach: "nothing happened"
   plus "a copy planted in place *i*", one per place. zogyn shows whichever lands the tile closest to the pointer.
2. **What does it look like?** A membrane layer draws round bodies and the stretchy neck between mother and bud.
   It never decides anything. Every frame it looks at which state zogyn picked and where the tiles are on screen.

The trick that ties them together: **the neck exists exactly when zogyn's pick is the "nothing happened" state.**
If the pick is a planted state, the cell has divided. So "splits near a place, rejoins near home" isn't extra
code. It falls out of the same choice that decides where the tile lands.
"""

nbRawHtml: """<h3>The model: a tile leaves a fresh copy behind</h3>"""

nbText: """
Every tile has an id, and the id is its key on screen (what your eye tracks). A source is a seed or any planted tile.
When you plant from a source, *the tile you hold* keeps its id and moves to the place, and the source gets a **fresh id**.
So the thing in your hand is the one that moves, and a new cell appears where it was.
This block runs natively (the figures below are drawn at build time) and in the page:
"""

nbCodeAnd(nbJsFromCode):
  import std/[strformat, strutils, math]
  import zogyn

  type
    Patch = object         # a garden: seeds that never move, places that fill up
      seeds: string        # letter of each seed
      seedId: seq[int]     # id of the tile sitting on each seed
      cell: string         # letter in each place, ' ' when empty
      cellId: seq[int]     # id of the tile in each place (0 when empty)
      next: int            # next fresh id
    Rule = proc (s: Patch, letter: char, place: int): bool

  func tkey(id: int): string = "t" & $id

  func source(s: Patch, key: string): (bool, int) =
    ## where the tile `key` sits: (true, seed j) or (false, place i)
    for j, id in s.seedId:
      if tkey(id) == key: return (true, j)
    for i, id in s.cellId:
      if id > 0 and tkey(id) == key: return (false, i)
    (false, -1)

  func letterOf(s: Patch, key: string): char =
    let (seed, i) = s.source(key)
    if i < 0: '\0' elif seed: s.seeds[i] else: s.cell[i]

  func plant(s: Patch, key: string, place: int): Patch =
    ## the held tile goes to `place`; its source gets a fresh tile
    result = s
    let (seed, i) = s.source(key)
    let id = if seed: s.seedId[i] else: s.cellId[i]
    result.cell[place] = s.letterOf(key)
    result.cellId[place] = id
    if seed: result.seedId[i] = s.next else: result.cellId[i] = s.next
    result.next = s.next + 1

  proc targets(s: Patch, key: string, rule: Rule): seq[Patch] =
    ## every state the drag can reach besides "nothing happened"
    let letter = s.letterOf(key)
    for place, c in s.cell:
      if c == ' ' and rule(s, letter, place): result.add s.plant(key, place)

  proc cellSpec(rule: Rule, snap: float): Spec[Patch] =
    result = proc (s: Patch, key: string): Behavior[Patch] =
      if s.letterOf(key) == '\0': return nil
      let places = s.targets(key, rule)
      if places.len == 0:
        closest(@[s])                    # nowhere to go: the only reachable state is home
      else:
        closest(places).within(snap).orElse(closest(@[s]))

nbText: """
That last proc is the whole interaction. `closest(places).within(snap)` picks a planted state once the tile is
within `snap` of a free place; `.orElse(closest(@[s]))` falls back to home anywhere else. A letter with no place left
gets `closest(@[s])`: still grabbable, but its only reachable state is the one it's in. Nothing else in the code
knows which letters are stuck.

The two rules differ in one line each:
"""

nbCodeAnd(nbJsFromCode):
  const copies = 2
  let gardenRule: Rule = proc (s: Patch, letter: char, place: int): bool =
    s.cell.count(letter) < copies

  let sudokuRule: Rule = proc (s: Patch, letter: char, place: int): bool =
    let (r, c) = (place div 6, place mod 6)
    for k in 0 ..< 36:
      if s.cell[k] == letter and (k div 6 == r or k mod 6 == c or
          (k div 12 == r div 2 and (k mod 6) div 3 == c div 3)): return false
    true

nbRawHtml: """<h3>The membrane: two circles and a neck</h3>"""

nbText: """
A dividing cell is two circles (mother and bud) and a neck between them. The neck is a closed path. On each side a
curve leaves the mother along its outline, dips to a waist and climbs onto the bud. All the character is in one number:
the waist's half-width, as a function of how far apart the two centres are. It starts fat (a bulge), thins fast,
then slowly, and never quite reaches zero. It's a thread that only breaks when zogyn says the cell has divided.
"""

nbCodeAnd(nbJsFromCode):
  const ink = "#24361f"
  const glazes = {'S': "#ffe08a", 'O': "#ffb38a", 'L': "#9fd8cb", 'A': "#ffb38a", 'I': "#c3e39b",
                  'P': "#f7a8bd", 'T': "#b9c9f3"}

  func glaze(c: char): string =
    for (k, v) in glazes:
      if k == c: return v
    "#e6e4cc"

  func smoothstep(a, b, x: float): float =
    let t = clamp((x - a) / (b - a), 0.0, 1.0)
    t * t * (3 - 2 * t)

  func waist(d, r: float): float =
    ## half-width of the neck between cells of radius r whose centres are d apart
    let t = clamp((d - 0.4 * r) / (4.2 * r), 0.0, 1.0)
    r * (0.85 - 0.74 * t)

  func neck(c1: Vec, r1: float, c2: Vec, r2: float, hw: float): string =
    ## SVG path joining two circles with a waist of half-width hw
    let d = dist(c1, c2)
    if d < 0.2 * r1 or hw < 0.3: return ""
    let u = (c2 - c1) * (1 / d)
    let n = vec(-u.y, u.x)
    # the neck meets each body wider than the waist: a fillet, as when a soap bubble pinches
    let a1 = arcsin(min(0.94, 1.05 * hw / r1 + 0.32))
    let a2 = arcsin(min(0.94, 1.05 * hw / r2 + 0.32))
    let m = c1 + u * (r1 + (d - r1 - r2) / 2)
    func f(v: Vec): string = &"{v.x:.1f} {v.y:.1f}"
    var side: array[2, string]
    for k, s in [1.0, -1.0]:
      let p1 = c1 + (u * cos(a1) + n * (s * sin(a1))) * r1
      let t1 = u * sin(a1) - n * (s * cos(a1))
      let p2 = c2 + (u * -cos(a2) + n * (s * sin(a2))) * r2
      let t2 = u * -sin(a2) - n * (s * cos(a2))
      let w = m + n * (s * hw)
      # handles: along the outline only as far as needed to drop to the waist, along the axis at the waist
      let h1 = clamp(1.4 * (r1 * sin(a1) - hw) / max(cos(a1), 0.2), 1.0, dist(p1, w) * 0.5)
      let h2 = clamp(1.4 * (r2 * sin(a2) - hw) / max(cos(a2), 0.2), 1.0, dist(p2, w) * 0.5)
      let (l1, l2) = (dist(p1, w) * 0.5, dist(p2, w) * 0.5)
      side[k] = if k == 0:
        &"M{f(c1)}L{f(p1)}C{f(p1 + t1 * h1)} {f(w - u * l1)} {f(w)}C{f(w + u * l2)} {f(p2 + t2 * h2)} {f(p2)}L{f(c2)}"
      else:
        &"L{f(p2)}C{f(p2 + t2 * h2)} {f(w + u * l2)} {f(w)}C{f(w - u * l1)} {f(p1 + t1 * h1)} {f(p1)}Z"
    side[0] & side[1]

  type Body = object
    at: Vec
    r: float
    letter: char
    neckTo: int        # index of the body it's joined to, or -1
    hw: float          # waist of that neck

  func membrane(bodies: openArray[Body], sw = 3.0): string =
    ## outline first (every shape stroked twice as wide), fills on top:
    ## the inner strokes are covered, only the outline of the union shows
    var ink2, fill: string
    for b in bodies:
      let c = &"""cx="{b.at.x:.1f}" cy="{b.at.y:.1f}" r="{b.r:.1f}""""
      ink2.add &"""<circle {c}/>"""
      fill.add &"""<circle {c} fill="{glaze(b.letter)}"/>"""
      if b.neckTo >= 0:
        let o = bodies[b.neckTo]
        let p = neck(b.at, b.r, o.at, o.r, b.hw)
        ink2.add &"""<path d="{p}"/>"""
        fill.add &"""<path d="{p}" fill="{glaze(b.letter)}"/>"""
    for b in bodies:           # a glint, so they read as soft and round
      fill.add &"""<ellipse cx="{b.at.x - b.r * 0.36:.1f}" cy="{b.at.y - b.r * 0.42:.1f}" rx="{b.r * 0.3:.1f}" ry="{b.r * 0.17:.1f}" fill="#fff" opacity=".55" transform="rotate(-30 {b.at.x - b.r * 0.36:.1f} {b.at.y - b.r * 0.42:.1f})"/>"""
    &"""<g fill="{ink}" stroke="{ink}" stroke-width="{2 * sw}" stroke-linejoin="round">{ink2}</g><g>{fill}</g>"""

  func glyph(letter: char, r: float): string =
    &"""<text y="{r * 0.36:.1f}" text-anchor="middle" font-size="{r * 1.05:.1f}" fill="{ink}">{letter}</text>"""

nbText: """
The outline is the old sign-painter's trick: draw every shape once with a stroke twice as thick as you want, then fill
them all on top. Where shapes overlap the fills hide the inner strokes, so only the outline of the union is left.
Here is the waist at work, drawn while this page was built. The mother stays put and the bud is pulled to the right:
"""

nbCode:
  var strip = """<div class="strip">"""
  let r = 22.0
  for (d, label) in [(0.0, "at rest"), (14.0, "budding"), (34.0, "pulled"), (60.0, "stretched"),
                     (88.0, "a thread"), (88.0, "divided")]:
    let joined = label != "divided"
    let k = if joined: 1 - 0.2 * smoothstep(0.0, 2.5 * r, d) else: 1.0
    let mother = Body(at: vec(30, 40), r: r * (1 - 0.06 * (1 - k)), letter: 'S', neckTo: -1)
    var bud = Body(at: vec(30 + d, 40), r: r * k, letter: 'S', neckTo: -1)
    if joined: (bud.neckTo, bud.hw) = (0, waist(d, r))
    strip.add &"""<figure><svg viewBox="0 0 150 80">{membrane([mother, bud], 2.4)}""" &
      &"""<g transform="translate(30 40)">{glyph('S', mother.r)}</g><g transform="translate({bud.at.x} 40) scale({k:.2f})">{glyph('S', r)}</g></svg><figcaption>{label}</figcaption></figure>"""
  strip.add "</div>"
nbRawHtml: strip

nbText: """
The bud also shrinks a little while it's stretched (`1 - 0.2·smoothstep`), and its letter shrinks with it, as if
it were still drawing material from its mother. Once it divides it springs back to full size.
"""

nbRawHtml: """<h3>Where the tiles are: one render, two layouts</h3>"""

nbText: """
zogyn needs a *render*: a pure function from the model to keyed, positioned items. Each item is only a letter
and an invisible hit circle. The bodies are the membrane's job. The garden puts its places on an arc and the board
on a 6×6 grid, so they get two layouts of the same render:
"""

nbCodeAnd(nbJsFromCode):
  type Layout = object
    r: float
    seedAt: proc (j, n: int): Vec
    placeAt: proc (i, n: int): Vec

  proc cellRender(lay: Layout): Render[Patch] =
    result = proc (s: Patch): seq[Item] =
      let tile = proc (c: char): string =
        &"""<circle r="{lay.r}" fill="transparent"/><g class="nuc">{glyph(c, lay.r)}</g>"""
      for j, id in s.seedId:
        result.add Item(key: tkey(id), pos: lay.seedAt(j, s.seeds.len), svg: tile(s.seeds[j]))
      for i, id in s.cellId:
        if id > 0:
          result.add Item(key: tkey(id), pos: lay.placeAt(i, s.cell.len), svg: tile(s.cell[i]))

  let garden = Layout(r: 22,
    seedAt: proc (j, n: int): Vec = vec(180 + (j.float - float(n - 1) / 2) * 80, 250),
    placeAt: proc (i, n: int): Vec =
      let a = if n == 1: PI / 2 else: PI * (0.92 - 0.84 * i.float / float(n - 1))
      vec(180 + 140 * cos(a), 232 - 150 * sin(a)))

  let board = Layout(r: 21,
    seedAt: proc (j, n: int): Vec = vec(45 + 54 * j.float, 392),
    placeAt: proc (i, n: int): Vec = vec(45 + 54 * float(i mod 6), 41 + 54 * float(i div 6)))

  proc newGarden(n: int): Patch =
    ## S and O are free; L already has both copies planted (when there is room to leave one place free)
    result = Patch(seeds: "SOL", seedId: @[1, 2, 3], cell: ' '.repeat(n), cellId: newSeq[int](n), next: 4)
    let ls = min(copies, n - 1)
    for k in 0 ..< ls:
      let place = if k == 0: 0 else: n - 1
      result.cell[place] = 'L'
      result.cellId[place] = result.next
      inc result.next

  proc newBoard(letters, givens: string): Patch =
    ## givens as in puzzle links: <row><col><letter>, dot separated
    result = Patch(seeds: letters, cell: ' '.repeat(36), cellId: newSeq[int](36), next: 1)
    for c in letters:
      result.seedId.add result.next
      inc result.next
    for g in givens.split('.'):
      let place = (ord(g[0]) - ord('0')) * 6 + ord(g[1]) - ord('0')
      result.cell[place] = g[2]
      result.cellId[place] = result.next
      inc result.next

nbText: "Because the engine has no DOM, we can drive a drag natively and check the behaviour while the page builds:"

nbCode:
  let rg = cellRender(garden)
  let sg = cellSpec(gardenRule, 1.7 * garden.r)
  let g0 = newGarden(5)
  echo "places: ", g0.cell.len, "   L stuck: ", g0.targets("t3", gardenRule).len == 0
  let spot = garden.placeAt(2, 5)
  let g1 = dragTo(sg, rg, g0, "t1", spot)                     # S released on the middle ring
  echo "S released on place 2 → '", g1.cell, "', the seed now holds t", g1.seedId[0]
  echo "S released halfway   → unchanged: ", dragTo(sg, rg, g0, "t1", vec(180, 170)) == g0
  echo "L released on place 2 → unchanged: ", dragTo(sg, rg, g0, "t3", spot) == g0

nbRawHtml: """<h3>The effect layer: drawing what zogyn picked</h3>"""

nbText: """
The membrane is a `<g>` slipped under zogyn's tiles. While anything moves, a `requestAnimationFrame` loop redraws it.
It reads each tile's *actual* position from its computed CSS transform, so the bodies follow zogyn's glide
(a CSS transition) without knowing about it. The loop decides three things:

- **Is the held tile joined?** Yes when zogyn's current pick is the committed state ("nothing happened"). Then it draws
  the mother at the tile's home with its letter, the bud under the pointer and the neck between them. After a release
  back home the tile glides back, and the neck follows it until they touch.
- **Did it just split or rejoin?** When the answer flips, it starts a small spring. A split makes mother and daughter
  wobble (a damped sine on their radius). A rejoin grows the neck back from nothing, with a little overshoot.
- **Is it stuck?** When zogyn offers a single reachable state, the tile is held on a leash: the pointer's offset `d` is
  squashed to `0.45·r·tanh(d / 0.45r)`, so it bulges towards you and never comes loose. The status line says why.

None of this touches zogyn: its stage already exposes the pick (`choice`), the candidates (`picker.lands`), the held
key and an `onMove` hook. The layer is about a hundred lines:
"""

nbRawHtml: "<details><summary>the effect layer (browser only)</summary>"
nbCodeDisplay(nbJsFromCode):
  import std/[dom, tables]
  import zogyn/stage

  proc now(): float {.importjs: "performance.now()".}
  proc raf(cb: proc ()) {.importjs: "requestAnimationFrame(#)".}
  proc onScreen(e: Element): Vec {.importjs:
    "(m => ({x: m.e, y: m.f}))(new DOMMatrix(getComputedStyle(#).transform))".}
  proc svgG(): Element {.importjs: "document.createElementNS('http://www.w3.org/2000/svg', 'g')".}
  proc setCss(e: Element, k, v: cstring) {.importjs: "#.style.setProperty(#, #)".}

  type Cells = ref object
    st: Stage[Patch]
    r: float
    layer, status: Element
    tether: string            # key still joined to its mother: held at home, or gliding back
    joined: bool              # was the held tile joined last frame?
    stuck: bool               # is (or was, while it glides back) the held tile one with nowhere to go?
    splitAt, joinAt: float    # when it last split / rejoined (ms)
    awake: float              # keep animating until then
    running: bool

  func spring(dt, amp: float): float =    # damped wobble, 1 at rest
    if dt > 600: 1.0 else: 1 + amp * exp(-dt / 140) * sin(dt / 26)

  proc node(c: Cells, key: string): Element =
    c.st.fg.querySelector(cstring(&"""[data-key="{key}"]"""))

  proc frame(c: Cells) =
    let (st, r, t) = (c.st, c.r, now())
    let held = st.dragKey
    let s = st.shown
    if held.len > 0:
      let home = st.choice.ok and st.choice.state == st.state
      if home != c.joined:
        if home: c.joinAt = t else: c.splitAt = t
        c.joined = home
      c.tether = if home: held else: ""
      c.stuck = st.picker.lands.len == 1
    var bodies: seq[Body]
    var onPage: seq[(string, Vec)]
    for e in st.fg.querySelectorAll("[data-key]"):
      onPage.add ($e.getAttribute("data-key"), e.onScreen)
    let homeOfTether = if c.tether.len > 0: st.render.locate(st.state, c.tether) else: nowhere
    let wob = spring(t - c.splitAt, 0.09)
    var motherGlyph = ""
    for (key, at) in onPage:
      let letter = s.letterOf(key)
      if letter == '\0': continue
      if key == c.tether:
        let d = dist(at, homeOfTether)
        if held.len == 0 and d < 0.6:
          c.tether = ""                       # glided home: one cell again
        else:
          let k = 1 - 0.2 * smoothstep(0.0, 2.5 * r, d)
          let grow = clamp((t - c.joinAt) / 160, 0.0, 1.0)
          let g = grow * (1 + 0.25 * sin(grow * PI))   # regrow the neck with a little overshoot
          bodies.add Body(at: homeOfTether, r: r * (1 - 0.06 * (1 - k)), letter: letter, neckTo: -1)
          bodies.add Body(at: at, r: r * k, letter: letter, neckTo: bodies.len - 1, hw: waist(d, r) * g)
          if not c.stuck: motherGlyph = &"""<g transform="translate({homeOfTether.x:.1f} {homeOfTether.y:.1f})">{glyph(letter, r)}</g>"""
          c.node(key).querySelector(".nuc").setCss("transform", cstring(&"scale({k:.3f})"))
          continue
      let near = key == held or dist(at, st.render.locate(st.state, held)) < 1
      var k = 1.0
      if held.len > 0 and near: k = wob
      bodies.add Body(at: at, r: r * k, letter: letter, neckTo: -1)
      let n = c.node(key)
      if not n.isNil: n.querySelector(".nuc").setCss("transform", "scale(1)")
    c.layer.innerHTML = cstring(membrane(bodies) & motherGlyph)

  proc kick(c: Cells, ms = 900.0) =
    c.awake = max(c.awake, now() + ms)
    if c.running: return
    c.running = true
    proc step() =
      c.frame()
      if c.st.dragKey.len > 0 or now() < c.awake: raf(step) else: c.running = false
    raf(step)

  proc leash(c: Cells) =
    ## a tile with nowhere to go bulges towards the pointer but stays attached
    let st = c.st
    if st.dragKey.len == 0 or st.picker.lands.len != 1: return
    let home = st.render.locate(st.state, st.dragKey)
    let off = st.at - home
    let d = norm(off)
    if d < 0.01: return
    let reach = 0.45 * c.r * tanh(d / (0.45 * c.r))
    c.node(st.dragKey).setCss("transform", tr(home + off * (reach / d)))

  proc grow(st: Stage[Patch], r: float, statusId: string, rule: Rule): Cells =
    let c = Cells(st: st, r: r, layer: svgG(), status: document.getElementById(cstring(statusId)))
    c.layer.setAttribute("class", "membrane")
    st.svg.insertBefore(c.layer, st.fg)
    st.onMove = proc () =
      c.leash()
      let held = st.dragKey
      if held.len > 0:
        let letter = st.state.letterOf(held)
        let n = st.state.targets(held, rule).len
        var msg = &"{letter} can go to {n} places"
        if n == 1: msg = &"{letter} can go to 1 place"
        if n == 0: msg = &"{letter} has nowhere to go, so it stays put"
        elif st.choice.ok and st.choice.state != st.state: msg = &"{letter} has split off: let go to plant it"
        c.status.textContent = cstring(msg)
      c.kick()
    c.kick()
    c
nbRawHtml: "</details>"

nbText: """
Two details made it feel right. The neck regrows over 160 ms instead of popping back, so a quick back-and-forth near
a ring reads as one hesitant cell, not as flicker. And tiles slide with a slightly springy easing
(`cubic-bezier(.2,.9,.25,1.15)`), so a bud released far away is *pulled* home and overshoots a hair before it settles.
"""

nbRawHtml: """<h2><span class="num">04 · NEXT</span>What this opens up</h2>"""

nbText: """
- **More kinds of source.** The model doesn't care what a source is. The clue words' letters can become seeds too,
  each with its own layout position, like the six shared letters and the board tiles here.
- **Taking a tile back.** For now a planted tile stays (use *reset*). A natural inverse is fusion: drop a tile
  onto a cell of the same letter and they merge. In zogyn's terms that's one more reachable state per same-letter cell.
- **Feel.** The waist curve, the 1.7·r snap radius and the spring constants are all one-liners. They're worth tuning
  on a phone with a thumb, not with a mouse.
"""

# ---------------------------------------------------------------- mount the two stages (needs every block above)
nbJsFromCode:
  import std/dom
  proc qsa(sel: cstring): seq[Element] {.importjs: "Array.from(document.querySelectorAll(#))".}

  var gardenN = 5
  proc rings(s: Patch): string =
    for i in 0 ..< s.cell.len:
      let p = garden.placeAt(i, s.cell.len)
      result.add &"""<circle cx="{p.x:.1f}" cy="{p.y:.1f}" r="{garden.r + 3}" fill="#eef0dc" stroke="#a7c27a" stroke-width="2" stroke-dasharray="5 5"/>"""
  let gst = mount("garden", 360, 290, newGarden(gardenN), cellRender(garden),
                  cellSpec(gardenRule, 1.7 * garden.r), backdrop = rings)
  let gc = grow(gst, garden.r, "garden-status", gardenRule)
  for b in qsa(".controls [data-n]"):
    let btn = b
    btn.addEventListener("click", proc (ev: Event) =
      for o in qsa(".controls [data-n]"): o.classList.remove("on")
      btn.classList.add("on")
      gardenN = parseInt($btn.getAttribute("data-n"))
      gst.setState(newGarden(gardenN)))
  document.getElementById("garden-reset").addEventListener("click", proc (ev: Event) =
    gst.setState(newGarden(gardenN)))

  let boardStart = newBoard("AILPST", "01S.33L.54P")
  proc grid(s: Patch): string =
    result = """<rect x="12" y="8" width="336" height="336" rx="18" fill="#eef0dc"/>"""
    for i in 0 ..< 36:
      let p = board.placeAt(i, 36)
      result.add &"""<circle cx="{p.x}" cy="{p.y}" r="{board.r + 2}" fill="#f8f7ea" stroke="#c9cfa6" stroke-width="1.5"/>"""
    for k in [2, 4]:
      let y = 14 + 54 * k
      result.add &"""<line x1="16" x2="344" y1="{y}" y2="{y}" stroke="#24361f" stroke-width="2.5" stroke-linecap="round"/>"""
    result.add """<line x1="180" x2="180" y1="12" y2="340" stroke="#24361f" stroke-width="2.5" stroke-linecap="round"/>"""
    result.add """<rect x="12" y="8" width="336" height="336" rx="18" fill="none" stroke="#24361f" stroke-width="3"/>"""
  let bst = mount("board", 360, 440, boardStart, cellRender(board), cellSpec(sudokuRule, 1.5 * board.r),
                  backdrop = grid)
  discard grow(bst, board.r, "board-status", sudokuRule)
  document.getElementById("board-reset").addEventListener("click", proc (ev: Event) =
    bst.setState(boardStart))

nbSave
