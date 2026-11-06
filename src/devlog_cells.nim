## Devlog post: tiles that divide like cells. An experiment (not in the game): a round tile you pull a copy out of,
## and push back together. The post shows one cell and explains how the animation is drawn; the dragging is zogyn.
## Writes devlog/cells/index.html.
import std/[json, os]
import nimib
import zogyn/nbstage
import style

const devlogStyle = """
<style>
html{-webkit-text-size-adjust:100%;text-size-adjust:100%}
.kicker{font:700 .72rem/1.2 var(--font-body,sans-serif);letter-spacing:.12em;text-transform:uppercase;color:var(--muted);margin:1.6rem 0 .3rem}
h3{font-size:22px;margin:30px 0 6px}
#one.zogyn-stage{--zg-ink:var(--ink);--zg-card:var(--card);--zg-muted:var(--muted);--zg-hot:var(--w0,#c01c3a);border:1.5px solid var(--line);
  border-radius:var(--radius,16px);box-shadow:none;max-width:440px;margin-left:auto;margin-right:auto}
.zogyn-stage .item{transition:transform .38s cubic-bezier(.2,.9,.25,1.15)}
.zogyn-stage .item.lifted{filter:none}
.membrane{pointer-events:none}
.status{text-align:center;font:600 15px var(--font-body);color:var(--muted);min-height:1.6em;margin:4px 0 0}
.controls{display:flex;flex-wrap:wrap;align-items:center;justify-content:center;gap:14px;margin:4px 0;font:13px "JetBrains Mono",monospace;color:var(--muted)}
.controls input{accent-color:var(--ink);vertical-align:-2px}
.scrub{margin:16px auto;max-width:440px;background:var(--card);border:1.5px solid var(--line);border-radius:16px;padding:8px 12px}
.scrub svg{display:block;width:100%;height:auto;overflow:visible}
.scrub svg text{font:600 10px "JetBrains Mono",monospace}
.scrub input[type=range]{width:100%;accent-color:var(--ink)}
.scrub figcaption{text-align:center;font:12px "JetBrains Mono",monospace;color:var(--muted)}
.strip{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:8px;margin:16px 0}
@media (min-width:620px){.strip{grid-template-columns:repeat(6,minmax(0,1fr))}}
.strip figure{margin:0;background:var(--card);border:1.5px solid var(--line);border-radius:12px;padding:4px}
.strip svg{display:block;width:100%;height:auto}
.strip figcaption{text-align:center;font:12px "JetBrains Mono",monospace;color:var(--muted)}
blockquote{margin:16px 0;padding:8px 16px;border-left:4px solid var(--accent);background:var(--card);border-radius:0 12px 12px 0}
blockquote p{margin:4px 0}
/* code: highlighted at build time, small, and scrolling inside its box */
pre{margin:14px 0;overflow-x:auto;-webkit-overflow-scrolling:touch;overscroll-behavior-x:contain;max-width:100%;padding:12px 14px;
  background:var(--card);border:1px solid var(--line);border-radius:12px;font:11px/1.5 "JetBrains Mono",monospace;tab-size:2}
pre,pre code{font-variant-ligatures:none;font-feature-settings:"calt" 0,"liga" 0}
pre code{display:block;width:max-content;min-width:100%;padding:0;background:none;border:0;font:inherit;color:var(--ink);white-space:pre}
@media (min-width:620px){pre{font-size:12.5px}}
.hljs-keyword{color:#9b2c6f;font-weight:600}.hljs-type{color:#1b3f9e}.hljs-built_in{color:#0a7552}
.hljs-string{color:#b1361e}.hljs-number,.hljs-literal{color:#8a5a00}.hljs-comment{color:#857a6b;font-style:italic}
</style>
"""

let root = currentSourcePath().parentDir.parentDir

nbInit
nb.doc.filename = root / "devlog" / "cells" / "index.html"
nb.doc.context["title"] = %"Parloku devlog · tiles that divide like cells"
nb.doc.context["stylesheet"] = %(pageStyle & devlogStyle)
nb.doc.context["highlight"] = %""
nb.doc.context["disableHighlightJs"] = %true
func pageHeader(blk: JsonNode, nb: Nb): string =
  """<header><span><a href="../../">parloku</a> · <a href="../">devlog</a></span><span>06 Nov 2026</span></header>"""
nb.backend.partials["header"] = pageHeader
nbZogynStyle()

nbRawHtml: """<script>document.body.dataset.skin = 'niki'</script>
<p class="kicker">DEVLOG · AN EXPERIMENT</p>
<h1>Tiles that divide like cells</h1>
<p class="lede">Not in the game yet, just a try: what if a tile were a cell? Pull a new one out of it, or push two
back together into one.</p>
"""

nbRawHtml: """<h2><span class="num">01 · ONE CELL</span>Divide it, then put it back together</h2>"""

nbText: """
Here's a single cell, without a letter. Drag it to the right. A bud swells and stretches on a neck that thins as you
go. Near an empty ring the bud splits away; come back and it joins again. Let go on a ring and you have two cells;
let go anywhere else and the bud is pulled home.

This cell may make **one** copy. Once it has, the copy can't divide, so it comes away whole: move it to the other
ring, or drop it back on its mother and the two **coalesce** into one.
"""

nbRawHtml: """
<div class="zogyn-stage" id="one"></div>
<p class="status" id="one-status"></p>
"""

nbRawHtml: """<h2><span class="num">02 · THE ANIMATION</span>Four small ideas</h2>"""

nbText: """
The cell isn't one picture. It's two circles and a bridge between them, redrawn on every frame while you drag.
"""

nbRawHtml: """<h3>1 · Two circles</h3>"""

nbText: """
The **mother** stays where the cell was. The **bud** follows your finger. Both are plain circles. While it's
stretched the bud is a bit smaller, as if it were still taking material from its mother, and it grows back to full
size once it splits off.
"""

nbRawHtml: """<h3>2 · A neck between them</h3>"""

nbText: """
Between the two circles goes a bridge, pinched in the middle like a soap bubble about to split. How pinched depends
on just **one thing: how far apart the circles are**. Close together, the neck is fat. Further apart it thins,
and it never quite breaks by itself: it becomes a thread. Pull the slider:
"""

nbRawHtml: """
<figure class="scrub">
<svg id="scrub" viewBox="0 0 300 120"></svg>
<input id="scrub-d" type="range" min="0" max="200" value="70" aria-label="distance between the two circles">
<div class="controls"><label><input type="checkbox" id="scrub-split"> split</label>
<label><input type="checkbox" id="scrub-built"> show how it's built</label>
<label><input type="checkbox" id="scrub-trick" checked> one outline</label></div>
<figcaption id="scrub-read"></figcaption>
</figure>
"""

nbText: """
With *show how it's built* on you see the pieces: the two circles, the distance `d` between their centres, and the
**waist**, the narrowest point of the neck. The only formula in the effect is the waist as a function of `d`. It
starts at 0.85 of the radius and shrinks steadily to 0.11 of it at about four radii apart.

Here is the same thing frozen at six distances (read it right to left and it's two cells coalescing):
"""

nbRawHtml: """<div class="strip" id="strip"></div>"""

nbRawHtml: """<h3>3 · One outline around everything</h3>"""

nbText: """
Untick *one outline* above: each shape gets its own border, and you see the seams. The fix is an old sign-painter's
trick. First draw every shape with a border twice as thick, then paint all the fills on top. The fills hide the
inner half of each border, so only the outline around the whole group is left. It's the same black outline the
game's tiles have.
"""

nbRawHtml: """<h3>4 · Make it move</h3>"""

nbText: """
The picture only depends on where the two centres are, so animating it is just redrawing it on every frame from
where the tiles really are on screen, even while they glide home. Three touches make it feel alive:

- **Splitting wobbles.** When the bud breaks free, both cells wobble for half a second, like jelly.
- **Rejoining regrows.** If you come back, the neck grows back over a sixth of a second instead of popping in,
  so hesitating near a ring looks like one undecided cell rather than flicker.
- **Coalescing is budding backwards.** As a free cell nears its twin a neck reaches out, getting *fatter* as they
  get closer. When it has slid in, the twin wobbles as it takes it in.
"""

nbRawHtml: "<details><summary>the drawing code (Nim)</summary>"
nbCodeAnd(nbJsFromCode):
  import std/[strformat, strutils, math, sequtils]
  import zogyn
  const ink = "#1e1e1e"
  const glazes = {'*': "#b5f0a0", 'A': "#ffb3c6", 'I': "#ffe066", 'L': "#8fd2ff",   # the Niki skin's pastels
                  'P': "#b5f0a0", 'S': "#ffb98a", 'T': "#d9b5ff"}

  func glaze(c: char): string =
    for (k, v) in glazes:
      if k == c: return v
    "#fff1e0"

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
    faded: bool        # a spent seed: drawn hollow

  func membrane(bodies: openArray[Body], sw = 2.5): string =
    ## outline first (every shape stroked twice as wide), fills on top:
    ## the inner strokes are covered, only the outline of the union shows
    var ink2, fill: string
    for b in bodies:
      let c = &"""cx="{b.at.x:.1f}" cy="{b.at.y:.1f}" r="{b.r:.1f}""""
      ink2.add &"""<circle {c}/>"""
      var hue = glaze(b.letter)
      if b.faded: hue = "#fff1e0"
      fill.add &"""<circle {c} fill="{hue}"/>"""
      if b.neckTo >= 0:
        let o = bodies[b.neckTo]
        let p = neck(b.at, b.r, o.at, o.r, b.hw)
        ink2.add &"""<path d="{p}"/>"""
        fill.add &"""<path d="{p}" fill="{glaze(b.letter)}"/>"""
    &"""<g fill="{ink}" stroke="{ink}" stroke-width="{2 * sw}" stroke-linejoin="round">{ink2}</g><g>{fill}</g>"""

  func glyph(letter: char, r: float): string =
    if letter == '*': return ""        # the plain cell has no letter
    &"""<text class="glyph" y="{r * 0.4:.1f}" text-anchor="middle" font-size="{r * 1.15:.1f}" fill="{ink}">{letter}</text>"""

nbRawHtml: "</details>"

nbRawHtml: """<h2><span class="num">03 · BEHIND THE DEMO</span>Who decides when it splits</h2>"""

nbText: """
The drawing never decides anything. Whether a pull makes a copy, and where it may land, comes from
[zogyn](https://github.com/pietroppeter/zogyn), the declarative dragging library. For the grabbed cell we list every
way the drag could end: *nothing happens*, *a copy in this ring*, and once it can't divide, *moved to this ring* or
*fused back into its twin*. zogyn keeps the ending nearest your finger. The animation only reads that pick: "nothing
happens" draws a neck to home, "a copy in a ring" means it has split, "fused" draws a neck reaching for the twin.
"""

nbRawHtml: "<details><summary>the code behind the demo (Nim)</summary>"
nbCodeAnd(nbJsFromCode):
  type
    Patch = object         # a garden: seeds that never move, places that fill up
      seeds: string        # letter of each seed
      seedId: seq[int]     # id of the tile sitting on each seed
      cell: string         # letter in each place, ' ' when empty
      cellId: seq[int]     # id of the tile in each place (0 when empty)
      absorbed: seq[(int, int)]  # (id, id it fused into): gliding into a sibling, until `tidy`
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

  func looksLike(s: Patch, key: string): char =
    ## the letter on screen, fusing tiles included
    result = s.letterOf(key)
    for (id, into) in s.absorbed:
      if tkey(id) == key: return s.letterOf(tkey(into))

  func tidy(s: Patch): Patch =
    result = s
    result.absorbed = @[]

  proc targets(s: Patch, key: string, rule: Rule): seq[Patch] =
    ## the copies the tile can bud: one state per place a copy may go
    let letter = s.letterOf(key)
    for place, c in s.cell:
      if c == ' ' and rule(s, letter, place): result.add s.plant(key, place)

  proc wholeMoves(s: Patch, key: string, rule: Rule): seq[Patch] =
    ## a tile that can't divide comes away whole: moved to another place, or fused into a sibling
    let (seed, i) = s.source(key)
    if seed or i < 0: return                 # seeds never move
    let letter = s.cell[i]
    var lifted = s
    lifted.cell[i] = ' '
    lifted.cellId[i] = 0
    for place, c in lifted.cell:
      if c == ' ' and place != i and rule(lifted, letter, place):
        var moved = lifted
        moved.cell[place] = letter
        moved.cellId[place] = s.cellId[i]
        result.add moved
    for j, id in s.seedId:
      if s.seeds[j] == letter:
        var fused = lifted
        fused.absorbed.add (s.cellId[i], id)
        result.add fused
    for k, id in s.cellId:
      if k != i and s.cell[k] == letter:
        var fused = lifted
        fused.absorbed.add (s.cellId[i], id)
        result.add fused

nbCodeAnd(nbJsFromCode):
  proc cellSpec(rule: Rule, snap: float): Spec[Patch] =
    result = proc (s: Patch, key: string): Behavior[Patch] =
      if s.letterOf(key) == '\0': return nil
      let buds = s.targets(key, rule)        # it can divide: bud a copy
      if buds.len > 0:
        return closest(buds).within(snap).orElse(closest(@[s]))
      let whole = s.wholeMoves(key, rule)    # it can't: move it, or fuse it into a sibling
      if whole.len == 0: return nil          # a spent seed gives nothing
      let fuse = whole.filterIt(it.absorbed.len > 0)
      let move = whole.filterIt(it.absorbed.len == 0)
      # siblings attract from further away than empty places do
      closest(fuse).within(2 * snap).orElse(closest(move).within(snap)).orElse(closest(@[s]))

nbCodeAnd(nbJsFromCode):
  let cellRule: Rule = proc (s: Patch, letter: char, place: int): bool =
    s.cell.count(letter) < 1               # one copy at a time

  type Layout = object
    r: float
    seedAt: proc (j, n: int): Vec
    placeAt: proc (i, n: int): Vec

  proc cellRender(lay: Layout): Render[Patch] =
    ## each item is only a letter (none, here) and an invisible hit circle: the bodies are the membrane's job
    result = proc (s: Patch): seq[Item] =
      let tile = proc (c: char): string =
        &"""<circle r="{lay.r}" fill="transparent"/><g class="nuc">{glyph(c, lay.r)}</g>"""
      for j, id in s.seedId:
        result.add Item(key: tkey(id), pos: lay.seedAt(j, s.seeds.len), svg: tile(s.seeds[j]))
      for i, id in s.cellId:
        if id > 0:
          result.add Item(key: tkey(id), pos: lay.placeAt(i, s.cell.len), svg: tile(s.cell[i]))
      for (id, into) in s.absorbed:          # a fusing tile lands on its partner
        let (seed, k) = s.source(tkey(into))
        var at = lay.placeAt(k, s.cell.len)
        if seed: at = lay.seedAt(k, s.seeds.len)
        result.add Item(key: tkey(id), pos: at, svg: tile(s.looksLike(tkey(id))))

  let single = Layout(r: 26,
    seedAt: proc (j, n: int): Vec = vec(72, 80),
    placeAt: proc (i, n: int): Vec = vec(214 + 92 * i.float, 80))

  proc newCell(): Patch =
    ## one plain cell and two empty places; it may make one copy
    Patch(seeds: "*", seedId: @[1], cell: "  ", cellId: @[0, 0], next: 2)

nbCodeDisplay(nbJsFromCode):
  import std/[dom, tables]
  import zogyn/stage

  proc now(): float {.importjs: "performance.now()".}
  proc raf(cb: proc ()) {.importjs: "requestAnimationFrame(#)".}
  proc later(cb: proc (), ms: int) {.importjs: "setTimeout(#, #)".}
  proc onScreen(e: Element): Vec {.importjs:
    "(m => ({x: m.e, y: m.f}))(new DOMMatrix(getComputedStyle(#).transform))".}
  proc svgG(): Element {.importjs: "document.createElementNS('http://www.w3.org/2000/svg', 'g')".}
  proc setCss(e: Element, k, v: cstring) {.importjs: "#.style.setProperty(#, #)".}

  type Cells = ref object
    st: Stage[Patch]
    r: float
    rule: Rule
    hollow: bool              # draw spent seeds hollow
    layer, status: Element
    tether: string            # key still joined to its mother: held at home, or gliding back
    joined: bool              # was the held bud joined last frame?
    splitAt, joinAt: float    # when it last split / rejoined (ms)
    mergeKey: string          # the tile that just took in a sibling, and when
    mergeAt: float
    awake: float              # keep animating until then
    running: bool

  func spring(dt, amp: float): float =    # damped wobble, 1 at rest
    if dt > 600: 1.0 else: 1 + amp * exp(-dt / 140) * sin(dt / 26)

  proc node(c: Cells, key: string): Element =
    c.st.fg.querySelector(cstring(&"""[data-key="{key}"]"""))

  proc fusing(s: Patch, key: string): string =
    ## the partner `key` is fusing into in `s`, or ""
    for (id, into) in s.absorbed:
      if tkey(id) == key: return tkey(into)

  proc frame(c: Cells) =
    let (st, r, t) = (c.st, c.r, now())
    let held = st.dragKey
    let s = st.shown
    let buds = held.len > 0 and st.state.targets(held, c.rule).len > 0   # dividing, not moving whole
    if held.len > 0:
      let home = st.choice.ok and st.choice.state == st.state
      if buds and home != c.joined:
        if home: c.joinAt = t else: c.splitAt = t
      c.joined = buds and home
      c.tether = ""
      if c.joined: c.tether = held
    var onPage: seq[(string, Vec)]
    for e in st.fg.querySelectorAll("[data-key]"):
      onPage.add ($e.getAttribute("data-key"), e.onScreen)
    let homeOfTether = if c.tether.len > 0: st.render.locate(st.state, c.tether) else: nowhere
    let wob = spring(t - c.splitAt, 0.09)
    var bodies: seq[Body]
    var index: Table[string, int]
    var motherGlyph = ""
    for (key, at) in onPage:
      let letter = s.looksLike(key)
      if letter == '\0': continue
      let n = c.node(key)
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
          index[key] = bodies.len - 1
          motherGlyph = &"""<g transform="translate({homeOfTether.x:.1f} {homeOfTether.y:.1f})">{glyph(letter, r)}</g>"""
          n.querySelector(".nuc").setCss("transform", cstring(&"scale({k:.3f})"))
          continue
      var k = 1.0
      if buds and (key == held or dist(at, st.render.locate(st.state, held)) < 1): k = wob
      if key == c.mergeKey: k = spring(t - c.mergeAt, 0.12)
      let spent = c.hollow and st.spec(st.state, key).isNil and st.state.letterOf(key) != '\0'
      bodies.add Body(at: at, r: r * k, letter: letter, neckTo: -1, faded: spent)
      index[key] = bodies.len - 1
      n.querySelector(".nuc").setCss("transform", "scale(1)")
      var o: cstring = "1"
      if spent: o = "0.4"
      n.querySelector(".nuc").setCss("opacity", o)
    # fusing pairs: the held tile over its chosen partner, or a released one gliding in
    var pairs: seq[(string, string)]
    if held.len > 0 and st.choice.ok and s.fusing(held).len > 0: pairs.add (held, s.fusing(held))
    for (id, into) in st.state.absorbed: pairs.add (tkey(id), tkey(into))
    for (a, b) in pairs:
      if a in index and b in index:
        let (ia, ib) = (index[a], index[b])
        let d = dist(bodies[ia].at, bodies[ib].at)
        if d > 0.6:
          bodies[ia].neckTo = ib
          bodies[ia].hw = waist(d, r)
    c.layer.innerHTML = cstring(membrane(bodies) & motherGlyph)

  proc kick(c: Cells, ms = 900.0) =
    c.awake = max(c.awake, now() + ms)
    if c.running: return
    c.running = true
    proc step() =
      c.frame()
      if c.st.dragKey.len > 0 or now() < c.awake: raf(step) else: c.running = false
    raf(step)

  proc tidyUp(c: Cells) =
    ## once a fused tile has glided into its partner, drop it from the model
    let st = c.st
    if st.state.absorbed.len == 0: return
    if st.dragKey.len > 0:
      later(proc () = c.tidyUp(), 200)
      return
    let (_, into) = st.state.absorbed[^1]
    c.mergeKey = tkey(into)
    c.mergeAt = now()
    st.setState(st.state.tidy)

  proc grow(st: Stage[Patch], r: float, statusId: string, rule: Rule, hollow = true): Cells =
    let c = Cells(st: st, r: r, rule: rule, hollow: hollow, layer: svgG(),
                  status: document.getElementById(cstring(statusId)))
    c.layer.setAttribute("class", "membrane")
    st.svg.insertBefore(c.layer, st.fg)
    st.onMove = proc () =
      let held = st.dragKey
      if held.len > 0:
        let letter = st.state.letterOf(held)
        var (it, twin) = ($letter, "another " & $letter)
        if letter == '*': (it, twin) = ("the cell", "its twin")
        let n = st.state.targets(held, rule).len
        var msg = &"{it} can bud a copy into {n} places"
        if n == 1: msg = &"{it} can bud a copy into 1 place"
        if n == 0: msg = &"{it} can't divide any more: move it, or drop it on {twin}"
        if st.choice.ok and st.choice.state != st.state:
          if n > 0: msg = &"{it} has split off: let go to plant it"
          elif st.choice.state.fusing(held).len > 0: msg = "let go and the two fuse into one"
          else: msg = &"let go to move {it} here"
        c.status.textContent = cstring(msg)
      else:
        c.status.textContent = ""
      c.kick()
    st.onCommit = proc (before, after: Patch) =
      if after.absorbed.len > 0: later(proc () = c.tidyUp(), 380)
    c.kick()
    c
nbRawHtml: "</details>"

# ---------------------------------------------------------------- mount the figures and the cell (needs every block above)
nbJsFromCode:
  import std/dom
  proc qsa(sel: cstring): seq[Element] {.importjs: "Array.from(document.querySelectorAll(#))".}

  # ---- the slider figure and the strip of section 2
  proc value(e: Element): cstring {.importjs: "#.value".}
  proc isOn(e: Element): bool {.importjs: "#.checked".}
  let byId = proc (id: string): Element = document.getElementById(cstring(id))

  proc twoCells(d, r: float, c1: Vec, split, trick: bool): string =
    var k = 1 - 0.2 * smoothstep(0.0, 2.5 * r, d)
    if split: k = 1.0
    let mother = Body(at: c1, r: r * (1 - 0.06 * (1 - k)), letter: '*', neckTo: -1)
    var bud = Body(at: c1 + vec(d, 0), r: r * k, letter: '*', neckTo: -1)
    if not split: (bud.neckTo, bud.hw) = (0, waist(d, r))
    if trick: return membrane([mother, bud], 2.2)
    let hue = glaze('*')
    for b in [mother, bud]:
      result.add &"""<circle cx="{b.at.x:.1f}" cy="{b.at.y:.1f}" r="{b.r:.1f}" fill="{hue}" stroke="{ink}" stroke-width="2.2"/>"""
    if not split:
      result.add &"""<path d="{neck(bud.at, bud.r, mother.at, mother.r, bud.hw)}" fill="{hue}" stroke="{ink}" stroke-width="2.2"/>"""

  proc scrub() =
    let r = 30.0
    let c1 = vec(52, 56)
    let d = parseFloat($byId("scrub-d").value)
    let split = byId("scrub-split").isOn
    var svg = twoCells(d, r, c1, split, byId("scrub-trick").isOn)
    let hot = "#c01c3a"
    let hw = waist(d, r)
    if byId("scrub-built").isOn:
      let c2 = c1 + vec(d, 0)
      var k = 1 - 0.2 * smoothstep(0.0, 2.5 * r, d)
      if split: k = 1.0
      let m = c1.x + r + (d - r - r * k) / 2
      svg.add &"""<g fill="none" stroke="{hot}" stroke-width="1.5">""" &
        &"""<circle cx="{c1.x}" cy="{c1.y}" r="{r * (1 - 0.06 * (1 - k)):.1f}" stroke-dasharray="4 3"/>""" &
        &"""<circle cx="{c2.x}" cy="{c2.y}" r="{r * k:.1f}" stroke-dasharray="4 3"/>""" &
        &"""<line x1="{c1.x}" y1="104" x2="{c2.x}" y2="104"/><line x1="{c1.x}" y1="99" x2="{c1.x}" y2="109"/>""" &
        &"""<line x1="{c2.x}" y1="99" x2="{c2.x}" y2="109"/></g>""" &
        &"""<circle cx="{c1.x}" cy="{c1.y}" r="2.5" fill="{hot}"/><circle cx="{c2.x}" cy="{c2.y}" r="2.5" fill="{hot}"/>""" &
        &"""<text x="{c1.x + d / 2:.1f}" y="118" text-anchor="middle" font-size="10" fill="{hot}">d</text>"""
      if not split and d > r:
        svg.add &"""<line x1="{m:.1f}" y1="{c1.y - hw:.1f}" x2="{m:.1f}" y2="{c1.y + hw:.1f}" stroke="{hot}" stroke-width="2.5"/>""" &
          &"""<text x="{m:.1f}" y="{c1.y - hw - 6:.1f}" text-anchor="middle" font-size="10" fill="{hot}">waist</text>"""
    byId("scrub").innerHTML = cstring(svg)
    var read = &"d = {d:.0f}, waist = {2 * hw:.0f} (radius 30)"
    if split: read = &"d = {d:.0f}: split, no neck"
    byId("scrub-read").textContent = cstring(read)

  for id in ["scrub-d", "scrub-split", "scrub-built", "scrub-trick"]:
    byId(id).addEventListener("input", proc (ev: Event) = scrub())
  scrub()

  var strip = ""
  for (d, label) in [(0.0, "at rest"), (14.0, "budding"), (34.0, "pulled"), (60.0, "stretched"),
                     (88.0, "a thread"), (88.0, "divided")]:
    strip.add &"""<figure><svg viewBox="0 0 150 80">{twoCells(d, 22, vec(30, 40), label == "divided", true)}</svg>""" &
      &"""<figcaption>{label}</figcaption></figure>"""
  byId("strip").innerHTML = cstring(strip)

  proc ringsOf(lay: Layout): proc (s: Patch): string =
    result = proc (s: Patch): string =
      for i in 0 ..< s.cell.len:
        let p = lay.placeAt(i, s.cell.len)
        result.add &"""<circle cx="{p.x:.1f}" cy="{p.y:.1f}" r="{lay.r + 3}" fill="#fff1e0" stroke="#1e1e1e" stroke-opacity=".35" stroke-width="2" stroke-dasharray="5 5"/>"""
  let ost = mount("one", 360, 160, newCell(), cellRender(single), cellSpec(cellRule, 1.7 * single.r),
                  backdrop = ringsOf(single))
  discard grow(ost, single.r, "one-status", cellRule, hollow = false)


nbSave
