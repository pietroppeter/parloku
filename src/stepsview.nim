## Draws the step solver's moves (src/stepsolver.nim) as a gallery: one board per step, with the reason shaded,
## each word's container as the game draws it, and the pencil marks. Used at build time by the devlog post
## "A puzzle, step by step" and in the browser by the spiega page; the CSS for .gal, .sl, .board is theirs.
import std/[strutils, sequtils, strformat]
import stepsolver

const galleryCss* = """
.gal{display:flex;overflow-x:auto;scroll-snap-type:x mandatory;scroll-behavior:smooth;-webkit-overflow-scrolling:touch;
  scrollbar-width:none;margin:16px -16px;padding:0 16px;gap:16px;cursor:pointer;-webkit-tap-highlight-color:transparent}
.gal::-webkit-scrollbar{display:none}
.sl{flex:0 0 100%;scroll-snap-align:center;scroll-snap-stop:always;max-width:460px}
.gal{scroll-padding:0 16px}
.sl .n{font:600 11px "JetBrains Mono",monospace;letter-spacing:.08em;text-transform:uppercase;color:var(--muted);margin-bottom:6px}
.sl .t{margin:.6em 0 0;font-size:16px;line-height:1.45}
.bar{height:4px;background:var(--line);border-radius:2px;margin-bottom:8px}.bar i{display:block;height:100%;background:var(--ink);border-radius:2px}
.board{width:100%;display:block;background:var(--card);border-radius:14px}
.board text{font-family:var(--font-glyph,sans-serif)}
.tag{display:inline-block;border-radius:8px;padding:0 6px;margin-left:4px;color:#fff}
.chips{display:flex;flex-direction:column;gap:5px;margin:0 0 8px}
.chip{display:flex;gap:3px;padding:3px 5px;border:2.5px solid;border-radius:14px;background:var(--card);align-self:flex-start}
.chip:nth-child(2){align-self:center}.chip:nth-child(3){align-self:flex-end}
.cl{width:22px;height:22px;border-radius:50%;display:grid;place-items:center;font:700 13px var(--font-glyph,sans-serif);
  border:1.5px solid var(--line);color:var(--muted)}
.cl.on{border-color:#1e1e1e;color:#1e1e1e}
.hint{color:var(--muted);font-size:14px;text-align:center;margin:0}
"""

type Explained* = object
  id*: string                ## the gallery's element id, also a prefix for the SVG mask ids
  letters*: string
  words*: seq[string]
  starts*, givens*: seq[int]
  ends*: bool               ## mark where each word starts and where its head is, as the game does since PR #30
                             ## (off in the dated devlog post, which keeps its look)
  steps*: seq[Step]
  solution*: string          ## the 36 letters of the solved board (to know where each word goes), or ""

const glazeCss* = ""
const glaze* = ["#ffb3c6", "#ffe066", "#8fd2ff", "#b5f0a0", "#ffb98a", "#d9b5ff"]   # the Niki skin, by letter order
const wordCol* = ["#c01c3a", "#0a7552", "#1b3f9e"]                                 # --w0 --w1 --w2
const cs = 40


proc nbrs(c: int): seq[int] =
  let (r, col) = (c div 6, c mod 6)
  if r > 0: result.add c - 6
  if r < 5: result.add c + 6
  if col > 0: result.add c - 1
  if col < 5: result.add c + 1

proc wordPath(e: Explained, w: int): seq[int] =
  ## where word w is spelled on the solved board (it reads one way only)
  var path, found: seq[int]
  let full = e.solution
  proc walk(c, k: int) =
    if found.len > 0 or c in path or full[c] != e.words[w][k]: return
    path.add c
    if k == e.words[w].len - 1: found = path
    else:
      for n in nbrs(c): walk(n, k + 1)
    discard path.pop
  if full.len == 36: walk(e.starts[w], 0)
  found

proc outline*(path: seq[int], w: int, id: string): string =
  ## the word's container, as the game draws it (src/parloku.nim, overlay) at this board's scale:
  ## a rounded square per cell and a band between neighbours, with the inside cut out by a mask
  let t = 2.0
  let rr = cs / 2 - 1.5 - t
  let corner = 7.0
  proc at(c: int): (float, float) = (float((c mod 6) * cs + cs div 2), float((c div 6) * cs + cs div 2))
  if path.len <= 1:
    let (x, y) = at(path[0])
    let h = rr + t / 2
    return &"""<rect x="{x - h:.1f}" y="{y - h:.1f}" width="{2 * h:.1f}" height="{2 * h:.1f}" rx="{corner - t / 2:.1f}" fill="none" stroke="{wordCol[w]}" stroke-width="{t}"/>"""
  var fillOut, fillIn = ""
  let (wOut, wIn, f) = (rr + t, rr, 5.0)
  for k in 1 .. path.len - 2:
    let (p0, p1, p2) = (at(path[k - 1]), at(path[k]), at(path[k + 1]))
    let a = ((p1[0] - p0[0]) / cs.float, (p1[1] - p0[1]) / cs.float)
    let b = ((p2[0] - p1[0]) / cs.float, (p2[1] - p1[1]) / cs.float)
    if abs(a[0] * b[0] + a[1] * b[1]) > 0.5: continue
    for (wd, r, inner) in [(wOut, f, false), (wIn, f + t, true)]:
      let kx = (p1[0] + wd * (b[0] - a[0]), p1[1] + wd * (b[1] - a[1]))
      let s1 = (kx[0] - a[0] * r, kx[1] - a[1] * r)
      let s2 = (kx[0] + b[0] * r, kx[1] + b[1] * r)
      let piece = &"M{kx[0]:.1f},{kx[1]:.1f}L{s1[0]:.1f},{s1[1]:.1f}Q{kx[0]:.1f},{kx[1]:.1f} {s2[0]:.1f},{s2[1]:.1f}Z"
      if inner: fillIn.add piece else: fillOut.add piece
  proc squares(wd, r: float, col: string): string =
    for k, c in path:
      let (x, y) = at(c)
      result.add &"""<rect x="{x - wd:.1f}" y="{y - wd:.1f}" width="{2 * wd:.1f}" height="{2 * wd:.1f}" rx="{r:.1f}" fill="{col}"/>"""
      if k > 0:
        let (qx, qy) = at(path[k - 1])
        let (x0, y0) = (min(x, qx), min(y, qy))
        let (dx, dy) = (abs(x - qx), abs(y - qy))
        if dx > dy: result.add &"""<rect x="{x0:.1f}" y="{y0 - wd:.1f}" width="{dx:.1f}" height="{2 * wd:.1f}" fill="{col}"/>"""
        else: result.add &"""<rect x="{x0 - wd:.1f}" y="{y0:.1f}" width="{2 * wd:.1f}" height="{dy:.1f}" fill="{col}"/>"""
  &"""<mask id="{id}" maskUnits="userSpaceOnUse" x="-4" y="-4" width="{6*cs+8}" height="{6*cs+8}">""" &
    squares(wOut, corner, "#fff") & &"""<path d="{fillOut}" fill="#fff"/>""" &
    squares(wIn, corner - t, "#000") & &"""<path d="{fillIn}" fill="#000"/></mask>""" &
    &"""<rect x="-4" y="-4" width="{6*cs+8}" height="{6*cs+8}" fill="{wordCol[w]}" mask="url(#{id})"/>"""

proc board*(e: Explained, n: int): string =
  ## the board after step n, as an SVG: the reason shaded, the containers of the words, the letters and pencil marks
  let st = e.steps[n]
  let (letters, starts, givens) = (e.letters, e.starts, e.givens)
  let b = st.board
  let cands = st.cands
  let kind = st.kind
  let unit = st.unit
  let elims = st.elims.mapIt(it[0])
  let cell = st.cell
  let w = st.word
  let isWord = kind in ["follow", "wordpaths", "wordpoint"] and w >= 0
  result = &"""<svg viewBox="-4 -4 {6*cs+8} {6*cs+8}" class="board" role="img" aria-label="board">"""
  if kind != "givens":
    for c in unit:
      let fill = if isWord: wordCol[w] & "22" else: "#f5c84a44"
      result.add &"""<rect x="{(c mod 6) * cs}" y="{(c div 6) * cs}" width="{cs}" height="{cs}" fill="{fill}" shape-rendering="crispEdges"/>"""
  for c in elims:
    result.add &"""<rect x="{(c mod 6) * cs}" y="{(c div 6) * cs}" width="{cs}" height="{cs}" fill="#ff000018" shape-rendering="crispEdges"/>"""
  # each word's start cell holds a soft tint of its colour, as in the game (64 px at cell 78)
  let sc = cs / 78
  for k in 0 ..< (if e.ends: e.words.len else: 0):
    let (x, y) = (float((starts[k] mod 6) * cs + cs div 2), float((starts[k] div 6) * cs + cs div 2))
    result.add &"""<rect x="{x - 32 * sc:.1f}" y="{y - 32 * sc:.1f}" width="{64 * sc:.1f}" height="{64 * sc:.1f}" rx="{10 * sc:.1f}" fill="{wordCol[k]}" opacity=".2"/>"""
  for i in 0 .. 6:
    let wx = if i mod 3 == 0: 2.5 else: 0.6
    let wy = if i mod 2 == 0: 2.5 else: 0.6
    result.add &"""<line x1="{i*cs}" y1="0" x2="{i*cs}" y2="{6*cs}" stroke="#1e1e1e" stroke-width="{wx}"/>"""
    result.add &"""<line x1="0" y1="{i*cs}" x2="{6*cs}" y2="{i*cs}" stroke="#1e1e1e" stroke-width="{wy}"/>"""
  var eyes = ""   # drawn last, over the letters
  for k in 0 ..< e.words.len:
    # the word's container over the letters it has so far, as the game shows it
    var sofar: seq[int]
    for c in e.wordPath(k):
      if b[c] == '.': break
      sofar.add c
    if sofar.len == 0: sofar = @[starts[k]]
    result.add outline(sofar, k, &"{e.id}o{n}w{k}")
    if e.ends and sofar.len >= 2:   # the head has two eyes on its front edge, looking the way the word goes, as in the game
      let (hx, hy) = (float((sofar[^1] mod 6) * cs + cs div 2), float((sofar[^1] div 6) * cs + cs div 2))
      let (ux, uy) = (float((sofar[^1] mod 6) - (sofar[^2] mod 6)), float((sofar[^1] div 6) - (sofar[^2] div 6)))
      let (nx, ny) = (-uy, ux)
      let ed = cs / 2 - 1.5 - 1.0          # the middle of the outline band (rr + t/2 in outline)
      for sgn in [-1.0, 1.0]:
        let (ex, ey) = (hx + ux * ed + nx * 13 * sc * sgn, hy + uy * ed + ny * 13 * sc * sgn)
        eyes.add &"""<circle cx="{ex:.1f}" cy="{ey:.1f}" r="{8.5 * sc:.1f}" fill="{wordCol[k]}"/>""" &
          &"""<circle cx="{ex:.1f}" cy="{ey:.1f}" r="{6 * sc:.1f}" fill="#fff"/>""" &
          &"""<circle cx="{ex + ux * 2.2 * sc:.1f}" cy="{ey + uy * 2.2 * sc:.1f}" r="{3 * sc:.1f}" fill="#222"/>"""
  if kind in ["follow", "wordpaths"] and unit.len > 1:
    let pts = unit.mapIt(&"{(it mod 6) * cs + cs div 2},{(it div 6) * cs + cs div 2}").join(" ")
    result.add &"""<polyline points="{pts}" fill="none" stroke="{wordCol[w]}" stroke-width="5" stroke-linecap="round" stroke-linejoin="round" opacity=".45"/>"""
  for c in 0 ..< 36:
    let (x, y) = ((c mod 6) * cs, (c div 6) * cs)
    if b[c] != '.':
      let given = c in givens
      let r = if given: 15 else: 13
      let sw = if c == cell: 3.5 elif given: 2.0 else: 1.2
      let fw = if given: "900" else: "700"
      result.add &"""<circle cx="{x + cs div 2}" cy="{y + cs div 2}" r="{r}" fill="{glaze[letters.find(b[c])]}" stroke="#1e1e1e" stroke-width="{sw}"/>"""
      result.add &"""<text x="{x + cs div 2}" y="{y + cs div 2 + 5}" text-anchor="middle" font-size="15" font-weight="{fw}">{b[c]}</text>"""
    else:
      for li, l in letters:
        if l in cands[c]:
          result.add &"""<text x="{x + 8 + (li mod 3) * 12}" y="{y + 13 + (li div 3) * 16}" text-anchor="middle" font-size="9" fill="#8a8378">{l}</text>"""
  result.add eyes & "</svg>"

const moveName = [("givens", "lettere date"), ("start", "inizio parola"), ("follow", "segui la parola"),
  ("wordpaths", "segui la parola"), ("hidden", "unico posto"), ("naked", "unica lettera"),
  ("wordpoint", "esclusione"), ("pointing", "esclusione")]

proc chips*(e: Explained, n: int): string =
  ## the words above the board, as in the game: a box in the word's colour, its letters lit as they are spelled
  let b = e.steps[n].board
  result = """<div class="chips">"""
  for k, word in e.words:
    var lit = 0
    for c in e.wordPath(k):
      if b[c] == '.': break
      inc lit
    result.add &"""<div class="chip" style="border-color:{wordCol[k]}">"""
    for i, ch in word:
      if i < lit: result.add &"""<span class="cl on" style="background:{glaze[e.letters.find(ch)]}">{ch}</span>"""
      else: result.add &"""<span class="cl">{ch}</span>"""
    result.add "</div>"
  result.add "</div>"

proc gallery*(e: Explained): string =
  ## one slide per step, in a row that scrolls sideways (the page adds the taps)
  let steps = e.steps
  result = &"""<div class="gal" id="{e.id}">"""
  for i, st in steps:
    let kind = st.kind
    var name = kind
    for (k, v) in moveName:
      if k == kind: name = v
    let w = st.word
    let col = if w >= 0 and kind notin ["hidden", "naked"]: wordCol[w] else: "#8a6a1f"
    let pct = (i + 1) * 100 div steps.len
    result.add &"""<section class="sl"><div class="bar"><i style="width:{pct}%"></i></div>"""
    result.add &"""<div class="n">passo {i} di {steps.len - 1}<span class="tag" style="background:{col}">{name}</span></div>"""
    result.add e.chips(i) & e.board(i)
    result.add &"""<p class="t">{st.text}</p></section>"""
  result.add "</div>"

