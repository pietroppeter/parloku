## Devlog post: twenty styles for Parloku, each after an artist or designer.
## Every section shows the play area in the new layout (three framed clue words, the board, six budding letters),
## then who inspired it, what was borrowed, links, and a small gallery. All drawing happens here at build time:
## the page is plain HTML and SVG with no script. Colours are checked while the page builds.
## Build: sh src/deps.sh && nim c -r -d:release src/devlog_styles.nim   (writes devlog/styles/index.html)
import std/[json, os, strutils, strformat, math, sequtils, uri, hashes]
import nimib
import devlog_styles/artists

let root = currentSourcePath().parentDir.parentDir

# ---------------------------------------------------------------- the position shown in every play area
const
  letters = "AILPST"
  solution = ["TSIPLA", "ALPTIS", "LITASP", "PASLTI", "SPLIAT", "ITASPL"]
  words = [("ITALIA", @[(5, 0), (5, 1), (5, 2), (4, 2), (4, 3), (4, 4)]),
           ("PASTA", @[(3, 0), (3, 1), (3, 2), (2, 2), (2, 3)]),
           ("ALPI", @[(1, 0), (1, 1), (1, 2), (0, 2)])]
  spelled = [6, 3, 0]                                  # how far each word is spelled in the position shown
  givens = [(0, 1), (3, 3), (5, 4)]
  extra = [(0, 5), (2, 5)]                             # a couple of loose placements, to look mid-game
  budLetter = 1                                        # the letter being pulled: I

func idx(c: char): int = letters.find(c)

proc placedCells(): seq[(int, int)] =
  for g in givens: result.add g
  for k, (w, path) in words:
    for i in 0 ..< spelled[k]:
      if path[i] notin result: result.add path[i]
  for e in extra: result.add e

# sanity: the paths spell the words in the solution
for (w, path) in words:
  for i, (r, c) in path: doAssert solution[r][c] == w[i], w

# ---------------------------------------------------------------- colour maths (for mixing and the audit)
type Rgb = tuple[r, g, b: float]
proc hex(s: string): Rgb =
  let h = s.strip(chars = {'#', ' '})
  (parseHexInt(h[0..1]) / 255, parseHexInt(h[2..3]) / 255, parseHexInt(h[4..5]) / 255)
proc toHex(c: Rgb): string =
  "#" & [c.r, c.g, c.b].mapIt(toHex(int(round(clamp(it, 0.0, 1.0) * 255)), 2).toLowerAscii).join
proc mix(a, b: string, t: float): string =
  let (x, y) = (hex(a), hex(b))
  toHex((x.r + (y.r - x.r) * t, x.g + (y.g - x.g) * t, x.b + (y.b - x.b) * t))
proc lin(u: float): float = (if u <= 0.04045: u / 12.92 else: pow((u + 0.055) / 1.055, 2.4))
proc luminance(c: Rgb): float = 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b)
proc contrast(a, b: string): float =
  let (x, y) = (luminance(hex(a)), luminance(hex(b)))
  (max(x, y) + 0.05) / (min(x, y) + 0.05)
proc lab(s: string): (float, float, float) =
  let c = hex(s)
  let (r, g, b) = (lin(c.r), lin(c.g), lin(c.b))
  let x = (r * 0.4124 + g * 0.3576 + b * 0.1805) / 0.95047
  let y = r * 0.2126 + g * 0.7152 + b * 0.0722
  let z = (r * 0.0193 + g * 0.1192 + b * 0.9505) / 1.08883
  proc f(v: float): float = (if v > 0.008856: cbrt(v) else: 7.787 * v + 16 / 116)
  (116 * f(y) - 16, 500 * (f(x) - f(y)), 200 * (f(y) - f(z)))
proc deltaE(a, b: string): float =
  let (p, q) = (lab(a), lab(b))
  sqrt((p[0] - q[0])^2 + (p[1] - q[1])^2 + (p[2] - q[2])^2)

type Audit = object
  ink, tiles, words, wordsOnCard, tileOnCell: float
proc audit(st: Style): Audit =
  result = Audit(ink: 99, tiles: 999, words: 999, wordsOnCard: 99, tileOnCell: 999)
  for i in 0..5:
    result.ink = min(result.ink, contrast(st.ink, st.g[i]))
    result.tileOnCell = min(result.tileOnCell, min(deltaE(st.g[i], st.ca), deltaE(st.g[i], st.cb)))
    for j in i + 1 .. 5: result.tiles = min(result.tiles, deltaE(st.g[i], st.g[j]))
  for i in 0..2:
    result.wordsOnCard = min(result.wordsOnCard, contrast(st.w[i], st.card))
    for j in i + 1 .. 2: result.words = min(result.words, deltaE(st.w[i], st.w[j]))

# ---------------------------------------------------------------- drawing
func f1(x: float): string = formatFloat(x, ffDecimal, 1)

proc blobPath(cx, cy, s: float, seed: int, amp: float): string =
  ## a smooth closed blob around (cx, cy): 8 points with varied radii, joined by Catmull-Rom curves
  var pts: seq[(float, float)]
  for k in 0 ..< 8:
    let a = k.float * PI / 4 + 0.3 * sin(seed.float)
    let rr = s * (1 + amp * sin(seed.float * 1.7 + k.float * 2.3) * (if k mod 2 == 0: 1.0 else: -0.6))
    pts.add (cx + rr * cos(a), cy + rr * sin(a))
  result = &"M{f1(pts[0][0])} {f1(pts[0][1])}"
  for k in 0 ..< 8:
    let (p0, p1, p2, p3) = (pts[(k + 7) mod 8], pts[k], pts[(k + 1) mod 8], pts[(k + 2) mod 8])
    let c1 = (p1[0] + (p2[0] - p0[0]) / 6, p1[1] + (p2[1] - p0[1]) / 6)
    let c2 = (p2[0] - (p3[0] - p1[0]) / 6, p2[1] - (p3[1] - p1[1]) / 6)
    result &= &"C{f1(c1[0])} {f1(c1[1])} {f1(c2[0])} {f1(c2[1])} {f1(p2[0])} {f1(p2[1])}"
  result &= "Z"

proc shapeSvg(st: Style, cx, cy, s: float, i: int, fill: string, extraAttr = ""): string =
  ## the bare tile shape (no letter), filled
  let sq = proc (rx: float): string =
    &"""<rect x="{f1(cx - s)}" y="{f1(cy - s)}" width="{f1(2 * s)}" height="{f1(2 * s)}" rx="{f1(rx * s)}" fill="{fill}"{extraAttr}/>"""
  let ci = &"""<circle cx="{f1(cx)}" cy="{f1(cy)}" r="{f1(s)}" fill="{fill}"{extraAttr}/>"""
  case st.shape
  of shCircle, shOffset, shRings, shDashed: ci
  of shRounded, shTilt: sq(0.36)
  of shSquare, shNested, shShade: sq(0.08)
  of shOutlined: sq(0.06)
  of shBlob: &"""<path d="{blobPath(cx, cy, s * 0.98, i * 7 + 3, 0.09)}" fill="{fill}"{extraAttr}/>"""
  of shPebble: &"""<path d="{blobPath(cx, cy, s * 0.97, i * 5 + 11, 0.06)}" fill="{fill}"{extraAttr}/>"""
  of shAlt: (if i mod 2 == 0: ci else: sq(0.1))
  of shArch:
    if i mod 2 == 0: sq(0.06)
    else: &"""<path d="M{f1(cx - s)} {f1(cy + s)}V{f1(cy)}A{f1(s)} {f1(s)} 0 0 1 {f1(cx + s)} {f1(cy)}V{f1(cy + s)}Z" fill="{fill}"{extraAttr}/>"""

proc tileSvg(st: Style, cx, cy, s: float, i: int, letter: char): string =
  let g = st.g[i]
  let ol = if st.outline != "": &""" stroke="{st.outline}" stroke-width="2"""" else: ""
  var body = ""
  var lx = cx
  var ly = cy
  var rot = ""
  case st.shape
  of shOffset:
    body = &"""<circle cx="{f1(cx + s * 0.2)}" cy="{f1(cy + s * 0.16)}" r="{f1(s * 0.96)}" fill="{g}"/>""" &
      &"""<circle cx="{f1(cx - s * 0.04)}" cy="{f1(cy - s * 0.04)}" r="{f1(s * 0.9)}" fill="none" stroke="{st.outline}" stroke-width="1.6"/>"""
  of shNested:
    let inner = mix(g, "#ffffff", 0.5)
    body = shapeSvg(st, cx, cy, s, i, g) &
      &"""<rect x="{f1(cx - s * 0.62)}" y="{f1(cy - s * 0.48)}" width="{f1(s * 1.24)}" height="{f1(s * 1.24)}" fill="{inner}"/>"""
    ly = cy + s * 0.14
  of shRings:
    body = shapeSvg(st, cx, cy, s, i, g) &
      &"""<circle cx="{f1(cx)}" cy="{f1(cy)}" r="{f1(s * 0.72)}" fill="none" stroke="{mix(g, st.ink, 0.3)}" stroke-width="1.4"/>"""
  of shDashed:
    body = shapeSvg(st, cx, cy, s, i, g, ol) &
      &"""<circle cx="{f1(cx)}" cy="{f1(cy)}" r="{f1(s * 0.8)}" fill="none" stroke="{st.ink}" stroke-width="2.2" stroke-dasharray="0.1 4.2" stroke-linecap="round"/>"""
  of shOutlined:
    body = shapeSvg(st, cx, cy, s, i, st.outline) &
      &"""<rect x="{f1(cx - s + 3.2)}" y="{f1(cy - s + 3.2)}" width="{f1(2 * s - 6.4)}" height="{f1(2 * s - 6.4)}" rx="2" fill="#ffffff"/>""" &
      &"""<rect x="{f1(cx - s + 6.4)}" y="{f1(cy - s + 6.4)}" width="{f1(2 * s - 12.8)}" height="{f1(2 * s - 12.8)}" rx="1" fill="{g}"/>"""
  of shShade:
    body = &"""<rect x="{f1(cx - s + s * 0.22)}" y="{f1(cy - s + s * 0.26)}" width="{f1(2 * s)}" height="{f1(2 * s)}" rx="{f1(0.08 * s)}" fill="{st.w[0]}" opacity=".18"/>""" &
      shapeSvg(st, cx, cy, s, i, g)
  of shTilt:
    body = shapeSvg(st, cx, cy, s, i, g)
    rot = &""" transform="rotate({(if i mod 2 == 0: -7 else: 6)} {f1(cx)} {f1(cy)})""""
  else:
    body = shapeSvg(st, cx, cy, s, i, g, ol)
  if st.shape == shArch and i mod 2 == 1: ly = cy + s * 0.12
  let fs = s * (if st.shape == shTilt: 1.3 else: 1.12)
  let filt = if st.rough: &""" filter="url(#rough-{st.id})"""" else: ""
  &"""<g{filt}>{body}</g><text class="glyph" x="{f1(lx)}" y="{f1(ly)}" font-size="{f1(fs)}" fill="{st.ink}"{rot}>{letter}</text>"""

proc neckPath(c1: (float, float), r1: float, c2: (float, float), r2: float, hw: float): string =
  ## a pinched neck joining two round bodies, waist half-width hw (a simple version of the garden devlog's)
  let (dx, dy) = (c2[0] - c1[0], c2[1] - c1[1])
  let d = sqrt(dx * dx + dy * dy)
  let (ux, uy) = (dx / d, dy / d)
  let (nx, ny) = (-uy, ux)
  let a = 0.9
  proc p(c: (float, float), r, sx, sy: float): (float, float) = (c[0] + r * (sx * ux + sy * nx), c[1] + r * (sx * uy + sy * ny))
  let p1 = p(c1, r1, cos(a), sin(a))
  let q1 = p(c1, r1, cos(a), -sin(a))
  let p2 = p(c2, r2, -cos(a), sin(a))
  let q2 = p(c2, r2, -cos(a), -sin(a))
  let m = ((c1[0] + c2[0]) / 2, (c1[1] + c2[1]) / 2)
  let w1 = (m[0] + nx * hw, m[1] + ny * hw)
  let w2 = (m[0] - nx * hw, m[1] - ny * hw)
  &"M{f1(c1[0])} {f1(c1[1])}L{f1(p1[0])} {f1(p1[1])}Q{f1(w1[0])} {f1(w1[1])} {f1(p2[0])} {f1(p2[1])}" &
    &"L{f1(c2[0])} {f1(c2[1])}L{f1(q2[0])} {f1(q2[1])}Q{f1(w2[0])} {f1(w2[1])} {f1(q1[0])} {f1(q1[1])}Z"

const
  cs = 52.0           # cell size
  x0 = 10.0
  y0 = 10.0
  boardW = 6 * cs
  rowY = y0 + boardW + 50
  svgW = boardW + 2 * x0
  svgH = rowY + 34

proc cellCentre(r, c: int): (float, float) = (x0 + (c.float + 0.5) * cs, y0 + (r.float + 0.5) * cs)

proc playSvg(st: Style): string =
  var s = &"""<svg class="board" viewBox="0 0 {f1(svgW)} {f1(svgH)}" role="img" aria-label="Parloku board in the {st.name} style">"""
  s &= "<defs>"
  if st.rough:
    s &= &"""<filter id="rough-{st.id}" x="-10%" y="-10%" width="120%" height="120%"><feTurbulence type="fractalNoise" baseFrequency=".09" numOctaves="2" seed="{st.id.len}"/>""" &
      &"""<feDisplacementMap in="SourceGraphic" scale="3.2"/></filter>"""
  for k, (w, path) in words:
    if spelled[k] == 0: continue
    var d = ""
    for i in 0 ..< spelled[k]:
      let (x, y) = cellCentre(path[i][0], path[i][1])
      d &= (if i == 0: "M" else: "L") & f1(x) & " " & f1(y)
    if spelled[k] == 1: d &= "h.01"
    # round joins only round the outer corners; each inner (concave) corner gets a fillet, in white for the
    # outer edge of the band and in black for its inner edge (same construction as the game's overlay)
    proc fillets(w, r: float, colour: string): string =
      for i in 1 ..< spelled[k] - 1:
        let (c, p, n) = (cellCentre(path[i][0], path[i][1]), cellCentre(path[i-1][0], path[i-1][1]), cellCentre(path[i+1][0], path[i+1][1]))
        let a = ((c[0] - p[0]) / cs, (c[1] - p[1]) / cs)
        let b = ((n[0] - c[0]) / cs, (n[1] - c[1]) / cs)
        if abs(a[0] - b[0]) + abs(a[1] - b[1]) < 0.01: continue   # straight on
        let kx = c[0] + w * (b[0] - a[0])
        let ky = c[1] + w * (b[1] - a[1])
        result &= &"""<path d="M{f1(kx)} {f1(ky)}L{f1(kx - a[0] * r)} {f1(ky - a[1] * r)}Q{f1(kx)} {f1(ky)} {f1(kx + b[0] * r)} {f1(ky + b[1] * r)}Z" fill="{colour}"/>"""
    let (outer, band) = (cs * 0.47, 3.0)
    s &= &"""<mask id="wl-{st.id}-{k}" maskUnits="userSpaceOnUse" x="0" y="0" width="{f1(svgW)}" height="{f1(svgH)}">""" &
      &"""<path d="{d}" fill="none" stroke="#fff" stroke-width="{f1(2 * outer)}" stroke-linecap="round" stroke-linejoin="round"/>""" &
      fillets(outer, 16, "#fff") &
      &"""<path d="{d}" fill="none" stroke="#000" stroke-width="{f1(2 * (outer - band))}" stroke-linecap="round" stroke-linejoin="round"/>""" &
      fillets(outer - band, 16 + band, "#000") & "</mask>"
  s &= "</defs>"
  # board
  s &= &"""<rect x="{f1(x0 - 4)}" y="{f1(y0 - 4)}" width="{f1(boardW + 8)}" height="{f1(boardW + 8)}" rx="12" fill="{st.card}"/>"""
  for r in 0..5:
    for c in 0..5:
      let fill = if ((r div 2) + (c div 3)) mod 2 == 0: st.ca else: st.cb
      s &= &"""<rect x="{f1(x0 + c.float * cs)}" y="{f1(y0 + r.float * cs)}" width="{f1(cs)}" height="{f1(cs)}" fill="{fill}" stroke="{mix(st.boxline, st.card, 0.82)}" stroke-width="1"/>"""
  for c in [3]:
    s &= &"""<rect x="{f1(x0 + c.float * cs - 1.25)}" y="{f1(y0)}" width="2.5" height="{f1(boardW)}" fill="{st.boxline}" opacity=".85"/>"""
  for r in [2, 4]:
    s &= &"""<rect x="{f1(x0)}" y="{f1(y0 + r.float * cs - 1.25)}" width="{f1(boardW)}" height="2.5" fill="{st.boxline}" opacity=".85"/>"""
  s &= &"""<rect x="{f1(x0)}" y="{f1(y0)}" width="{f1(boardW)}" height="{f1(boardW)}" fill="none" stroke="{st.boxline}" stroke-width="2.5" rx="3"/>"""
  # tiles on the board
  for (r, c) in placedCells():
    let (x, y) = cellCentre(r, c)
    let ch = solution[r][c]
    s &= tileSvg(st, x, y, cs * 0.38, idx(ch), ch)
    if (r, c) in givens:
      s &= &"""<circle cx="{f1(x)}" cy="{f1(y)}" r="{f1(cs * 0.31)}" fill="none" stroke="{st.ink}" stroke-width="1" stroke-dasharray="1.5 2.5" opacity=".45"/>"""
  # word outlines: a ring before the first letter, then the outline of the spelled path
  for k, (w, path) in words:
    if spelled[k] == 0:
      let (x, y) = cellCentre(path[0][0], path[0][1])
      s &= &"""<circle cx="{f1(x)}" cy="{f1(y)}" r="{f1(cs * 0.44)}" fill="none" stroke="{st.w[k]}" stroke-width="3.2"/>"""
    else:
      s &= &"""<rect x="0" y="0" width="{f1(svgW)}" height="{f1(svgH)}" fill="{st.w[k]}" mask="url(#wl-{st.id}-{k})"/>"""
  # six budding letters below the board, one of them mid-division
  let r0 = 21.0
  for i in 0..5:
    let (x, _) = cellCentre(0, i)
    if i == budLetter:
      let mother = (x, rowY)
      let bud = (x + 22, rowY - 31)
      let rb = r0 * 0.86
      let filt = if st.rough: " filter=\"url(#rough-" & st.id & ")\"" else: ""
      s &= &"""<g{filt}><path d="{neckPath(mother, r0 * 0.96, bud, rb, 6.5)}" fill="{st.g[i]}"/></g>"""
      s &= tileSvg(st, mother[0], mother[1], r0 * 0.96, i, letters[i])
      s &= &"""<g opacity=".96">{tileSvg(st, bud[0], bud[1], rb, i, letters[i])}</g>"""
    else:
      s &= tileSvg(st, x, rowY, r0, i, letters[i])
  s & "</svg>"

proc cluesHtml(st: Style): string =
  result = """<div class="clues">"""
  for k, (w, path) in words:
    result &= &"""<div class="clue" style="--wk:{st.w[k]}">"""
    for i, ch in w:
      if i < spelled[k]:
        result &= &"""<span class="l on" style="background:{st.g[idx(ch)]};color:{st.ink}">{ch}</span>"""
      else:
        result &= &"""<span class="l">{ch}</span>"""
    result &= "</div>"
  result &= "</div>"

# ---------------------------------------------------------------- gallery sketches
proc rnd(seed: var uint32): float =
  seed = seed * 1664525'u32 + 1013904223'u32
  float(seed shr 8) / float(1 shl 24)

proc sketch(st: Style, motif: string): string =
  ## a small abstract sketch made only from the style's palette: a reminder of the work, not a copy of it
  var seed = uint32(abs(hash(st.id & motif)) mod 100000 + 7)
  let W = 160.0
  let H = 100.0
  let g = st.g
  let dk = st.w
  var s = &"""<svg viewBox="0 0 {W} {H}" aria-hidden="true"><rect width="{W}" height="{H}" fill="{st.card}"/>"""
  template pick(): string = g[int(rnd(seed) * 6) mod 6]
  let kind = case motif
    of "dots", "pumpkin", "net", "mosaic", "gond", "gond2": "dots"
    of "rings", "spiral", "petals", "target", "swan": "rings"
    of "nested", "interaction", "plain", "constellation": "nested"
    of "grid", "goldgrid", "pencil", "blocks", "room", "boxes", "counting": "grid"
    of "bands", "pale", "pale2", "swash", "totem", "carlton", "rules", "sails": "bands"
    of "waves", "beds", "snake", "fountain": "waves"
    of "blobs", "leaves", "seeds", "flowers", "apple", "birds", "fish", "tree", "offset": "blobs"
    of "bottles", "bottles2", "towers", "cone", "puppets", "hatch": "bottles"
    of "houses", "town", "house", "walls", "pool", "gilardi", "stage", "journey", "stairs", "cars", "boats": "walls"
    of "jigsaw", "slots", "planks", "patch", "cutout", "ship", "plate", "mask": "jigsaw"
    of "chevron", "ndebele", "ndebele2", "altar", "face": "chevron"
    else: "type"
  case kind
  of "dots":
    for k in 0 ..< 26:
      s &= &"""<circle cx="{f1(rnd(seed) * W)}" cy="{f1(rnd(seed) * H)}" r="{f1(3 + rnd(seed) * 9)}" fill="{pick()}"/>"""
    if motif == "pumpkin": s &= &"""<ellipse cx="80" cy="56" rx="38" ry="30" fill="{g[1]}" stroke="{dk[1]}" stroke-width="3"/>"""
  of "rings":
    for k in 0 ..< 6:
      s &= &"""<circle cx="{f1(50 + k.float * 4)}" cy="50" r="{f1(44 - k.float * 7)}" fill="{g[k]}"/>"""
    s &= &"""<circle cx="122" cy="40" r="22" fill="{g[4]}"/><circle cx="122" cy="40" r="12" fill="{g[0]}"/>"""
  of "nested":
    for k in 0 ..< 4:
      let sz = 90 - k.float * 20
      s &= &"""<rect x="{f1(80 - sz / 2)}" y="{f1(96 - sz - k.float * 2)}" width="{f1(sz)}" height="{f1(sz)}" fill="{g[(k * 2 + motif.len) mod 6]}"/>"""
  of "grid":
    for r in 0..3:
      for c in 0..5:
        let fill = if rnd(seed) < 0.55: pick() else: st.cb
        s &= &"""<rect x="{f1(12 + c.float * 23)}" y="{f1(8 + r.float * 22)}" width="21" height="20" rx="2" fill="{fill}"/>"""
    if motif in ["goldgrid", "pencil"]:
      for k in 0..10: s &= &"""<line x1="0" y1="{f1(k.float * 10)}" x2="{W}" y2="{f1(k.float * 10)}" stroke="{st.muted}" stroke-width=".5" opacity=".6"/>"""
  of "bands":
    for k in 0 ..< 8:
      s &= &"""<rect x="0" y="{f1(k.float * H / 8)}" width="{W}" height="{f1(H / 8 + 0.5)}" fill="{g[k mod 6]}"/>"""
  of "waves":
    for k in 0 ..< 6:
      var d = &"M0 {f1(12 + k.float * 16)}"
      for x in countup(0, 160, 20):
        d &= &" Q{f1(x.float + 10)} {f1(k.float * 16 + (if (x div 20) mod 2 == 0: 0.0 else: 24.0))} {f1(x.float + 20)} {f1(12 + k.float * 16)}"
      s &= &"""<path d="{d}" fill="none" stroke="{(if k mod 2 == 0: dk[0] else: g[k])}" stroke-width="6" stroke-linecap="round"/>"""
  of "blobs":
    for k in 0 ..< 7:
      s &= &"""<path d="{blobPath(rnd(seed) * W, rnd(seed) * H, 12 + rnd(seed) * 16, k + motif.len, 0.22)}" fill="{pick()}"/>"""
  of "bottles":
    var x = 14.0
    for k in 0 ..< 6:
      let w = 16 + rnd(seed) * 10
      let h = 40 + rnd(seed) * 40
      s &= &"""<rect x="{f1(x)}" y="{f1(92 - h)}" width="{f1(w)}" height="{f1(h)}" rx="{f1(w / 3)}" fill="{g[k]}"/>"""
      s &= &"""<rect x="{f1(x + w / 2 - 3)}" y="{f1(84 - h)}" width="6" height="12" rx="2" fill="{g[k]}"/>"""
      x += w + 6
    s &= &"""<rect x="0" y="92" width="{W}" height="8" fill="{st.cb}"/>"""
  of "walls":
    s &= &"""<rect width="{W}" height="{H}" fill="{g[motif.len mod 6]}"/>"""
    s &= &"""<rect x="18" y="20" width="58" height="80" fill="{g[(motif.len + 2) mod 6]}"/>"""
    s &= &"""<rect x="76" y="44" width="70" height="56" fill="{g[(motif.len + 4) mod 6]}"/>"""
    s &= &"""<rect x="90" y="58" width="16" height="22" fill="{st.card}"/><rect x="40" y="38" width="14" height="18" fill="{st.card}"/>"""
  of "jigsaw":
    for r in 0..2:
      for c in 0..3:
        s &= &"""<rect x="{f1(8 + c.float * 37)}" y="{f1(6 + r.float * 30)}" width="35" height="28" rx="3" fill="{pick()}" stroke="{st.ink}" stroke-width="1.2"/>"""
        s &= &"""<circle cx="{f1(43 + c.float * 37)}" cy="{f1(20 + r.float * 30)}" r="5" fill="{pick()}" stroke="{st.ink}" stroke-width="1.2"/>"""
  of "chevron":
    for k in 0 ..< 5:
      let x = 10 + k.float * 29
      s &= &"""<path d="M{f1(x)} 86L{f1(x + 14)} 20L{f1(x + 28)} 86Z" fill="{g[k]}" stroke="#151515" stroke-width="4"/>"""
    s &= &"""<rect x="0" y="86" width="{W}" height="14" fill="#151515"/>"""
  else:
    let word = st.name.split(' ')[0].toUpperAscii[0..min(3, st.name.split(' ')[0].len - 1)]
    for k, ch in word:
      s &= &"""<rect x="{f1(10 + k.float * 36)}" y="{f1(22 + (k mod 2).float * 10)}" width="34" height="46" rx="8" fill="{g[k mod 6]}"/>"""
      s &= &"""<text x="{f1(27 + k.float * 36)}" y="{f1(46 + (k mod 2).float * 10)}" class="glyph" font-size="30" fill="{st.ink}">{ch}</text>"""
  s & "</svg>"

proc searchUrl(q: string): string = "https://www.google.com/search?tbm=isch&q=" & encodeUrl(q)

proc galleryHtml(st: Style): string =
  result = """<div class="gallery">"""
  for wk in st.works:
    let q = st.name.replace(" and Memphis", "") & " " & wk.title
    result &= &"""<figure><a class="pic" href="{searchUrl(q)}" target="_blank" rel="noopener">{sketch(st, wk.motif)}<span class="go">see it ↗</span></a>""" &
      &"""<figcaption><b>{wk.title}</b>{(if wk.year != "": " · " & wk.year else: "")}<br><span>{wk.note}</span>""" &
      (if wk.url != "": &""" · <a href="{wk.url}" target="_blank" rel="noopener">about</a>""" else: "") &
      "</figcaption></figure>"
  result &= "</div>"

proc skinCss(st: Style): string =
  var v = &"[data-skin={st.id}]{{\n  --bg:{st.bg}; --card:{st.card}; --ink:{st.ink}; --muted:{st.muted}; --ca:{st.ca}; --cb:{st.cb}; --boxline:{st.boxline};\n "
  for i in 0..5: v &= &" --g{i}:{st.g[i]};"
  v &= "\n "
  for i in 0..5: v &= &" --i{i}:{st.ink};"
  v &= "\n "
  for i in 0..2: v &= &" --w{i}:{st.w[i]};"
  v &= &"\n  --font-glyph:\"{st.font}\",system-ui,sans-serif; --glyph-weight:{st.weight};"
  let (ts, tw) = (if st.outline == "": ("none", "0") else: (st.outline, "2"))
  v &= &" --tstroke:{ts}; --tsw:{tw};\n}}"
  v

# ---------------------------------------------------------------- page
const fontFamilies = ["Nunito:wght@400;700;800", "Space+Grotesk:wght@500;700", "JetBrains+Mono:wght@500",
  "Archivo:wght@800", "Lexend:wght@700", "Kalam:wght@700", "Outfit:wght@700", "Fraunces:wght@600",
  "M+PLUS+Rounded+1c:wght@800", "Baloo+2:wght@800", "Comfortaa:wght@700", "Bungee", "Jost:wght@600",
  "Sniglet:wght@800", "Archivo+Black", "Caveat+Brush", "EB+Garamond:wght@700", "Shrikhand", "Rubik:wght@800",
  "DM+Serif+Display", "Unbounded:wght@700", "Spectral:wght@600", "Yatra+One"]

proc pageCss(): string =
  result = """
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?""" & fontFamilies.mapIt("family=" & it).join("&") & """&display=swap">
<style>
*{box-sizing:border-box}
[hidden]{display:none!important}
:root{--page:#fbfaf7;--text:#2a2a2a;--soft:#6b665c;--rule:#e6e1d6;
  padding:env(safe-area-inset-top,0) env(safe-area-inset-right,0) env(safe-area-inset-bottom,0) env(safe-area-inset-left,0)}
html{background:var(--page)}
body{margin:0 auto;max-width:720px;padding:0 0 60px;color:var(--text);font:17px/1.6 Nunito,system-ui,sans-serif;background:var(--page)}
header,footer .nb-box{display:flex;justify-content:space-between;gap:10px;flex-wrap:wrap;font:13px "JetBrains Mono",monospace;color:var(--soft);padding:12px 16px}
header a,footer a{color:var(--soft)}
main>*:not(.st){margin-left:16px;margin-right:16px}
h1,h2,h3{font-family:"Space Grotesk",system-ui,sans-serif;line-height:1.1;letter-spacing:-.01em}
h1{font-size:clamp(38px,9vw,60px);margin:14px 0 6px}
.kicker{font:700 12px "JetBrains Mono",monospace;letter-spacing:.12em;color:var(--soft);margin:20px 0 0}
.lede{font-size:19px;color:var(--soft)}
a{color:#2c5aa0;text-underline-offset:3px}
code{font:13.5px "JetBrains Mono",monospace;background:#f0ede5;padding:1px 5px;border-radius:4px}
.toc{display:flex;flex-wrap:wrap;gap:6px;margin:14px 0 6px;padding:0;list-style:none}
.toc a{display:inline-block;font:700 13px Nunito,sans-serif;text-decoration:none;color:var(--text);background:#fff;border:1.5px solid var(--rule);border-radius:999px;padding:3px 10px}
/* one style */
.st{background:var(--bg);color:var(--ink);padding:26px 16px 30px;margin:34px 0 0;border-top:1px solid var(--rule)}
.st h2{margin:0 0 2px;font-size:30px;color:var(--ink)}
.st h2 .n{display:block;font:600 12px "JetBrains Mono",monospace;letter-spacing:.12em;color:var(--muted);margin-bottom:6px}
.st .sub{margin:0 0 14px;color:var(--muted);font-size:15px}
.glyph{font-family:var(--font-glyph);font-weight:var(--glyph-weight);text-anchor:middle;dominant-baseline:central}
.play{background:var(--card);border-radius:22px;padding:14px 12px 10px;max-width:400px;margin:0 auto;box-shadow:0 1px 0 rgba(0,0,0,.04)}
.clues{display:flex;flex-direction:column;gap:8px;margin:2px 4px 10px}
.clue{display:flex;gap:4px;padding:5px 9px;border:3px solid var(--wk);border-radius:999px;background:var(--card)}
.clue:nth-child(1){align-self:flex-start}.clue:nth-child(2){align-self:center}.clue:nth-child(3){align-self:flex-end}
.clue .l{width:27px;height:30px;border-radius:8px;display:grid;place-items:center;font:var(--glyph-weight) 18px var(--font-glyph);
  border:1.5px dashed color-mix(in srgb,var(--wk) 45%,transparent);color:color-mix(in srgb,var(--wk) 60%,transparent)}
.clue .l.on{border:1.5px solid transparent}
svg.board{display:block;width:100%;height:auto}
.checks{font:500 11.5px/1.5 "JetBrains Mono",monospace;color:var(--muted);text-align:center;margin:10px 0 0}
.insp{max-width:620px;margin:22px auto 0;font-size:16px}
.insp h3{font-size:21px;margin:0 0 6px;color:var(--ink)}
.insp p{margin:8px 0}
.insp .took{border-left:4px solid var(--w0);padding:2px 0 2px 12px}
.insp a{color:var(--w2)}
.links{display:flex;flex-wrap:wrap;gap:6px;margin:10px 0 4px;padding:0;list-style:none}
.links a{display:inline-block;font:700 13px Nunito,sans-serif;text-decoration:none;color:var(--ink);border:2px solid var(--w1);border-radius:999px;padding:2px 10px;background:var(--card)}
.gallery{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:10px;margin:14px 0 4px}
@media (min-width:620px){.gallery{grid-template-columns:repeat(4,minmax(0,1fr))}}
.gallery figure{margin:0;background:var(--card);border-radius:14px;overflow:hidden;border:1px solid color-mix(in srgb,var(--ink) 10%,transparent)}
.gallery .pic{display:block;position:relative}
.gallery svg{display:block;width:100%;height:auto}
.gallery .go{position:absolute;right:6px;bottom:6px;font:700 11px Nunito,sans-serif;background:var(--ink);color:var(--card);border-radius:999px;padding:1px 8px}
.gallery figcaption{padding:6px 9px 9px;font-size:13px;line-height:1.35}
.gallery figcaption span{color:var(--muted)}
details.css{margin:14px 0 0;font-size:13px}
details.css summary{cursor:pointer;font:600 12.5px "JetBrains Mono",monospace;color:var(--muted)}
details.css pre{overflow-x:auto;background:var(--card);border-radius:10px;padding:10px 12px;font:12px/1.5 "JetBrains Mono",monospace;margin:8px 0 0;color:var(--ink)}
.end{margin-top:40px}
</style>
"""
  for st in styles:
    result &= "<style>" & skinCss(st) & (if st.deco != "": &"\n[data-skin={st.id}] .play{{{st.deco}}}" else: "") & "</style>\n"

nbInit
nb.doc.filename = root / "devlog" / "styles" / "index.html"
nb.doc.context["title"] = %"Parloku devlog · twenty styles"
nb.doc.context["stylesheet"] = %pageCss()
nb.doc.context["highlight"] = %""
nb.doc.context["disableHighlightJs"] = %true
func pageHeader(blk: JsonNode, nb: Nb): string =
  """<header><span><a href="../../">parloku</a> · devlog</span><span>05 Nov 2026</span></header><main>"""
nb.backend.partials["header"] = pageHeader

nbRawHtml: """
<p class="kicker">DEVLOG · STYLES</p>
<h1>Twenty styles for Parloku</h1>
<p class="lede">Twenty artists and designers, none of them from the first round of skins. Each gets a play area in the new
layout, then a note on who they are and what I borrowed, with links and a small gallery. Just scroll.</p>
"""

nbText: """
Every play area shows the same moment of puzzle 1 (ITALIA · PASTA · ALPI). ITALIA is spelled, PASTA is half done, and
ALPI has not started, so its start cell has only the ring. Each area has the parts of the new layout and nothing else:

- **Three clue words**, one per line, aligned left, centre and right, each in a dark frame. No numbers: the frame's
  colour is the word's colour on the board.
- **The board**, with the outline of each spelled word drawn in its colour, and a **ring** on the start cell of a word
  that has no letters yet. A dotted ring marks the three given letters, as in the game.
- **Six budding letters** below the board, one per symbol. The **I** is being pulled, so a copy buds off it on a neck,
  as in the cell-division prototype.

Each style picks **six pastel colours** for the letters, **three dark colours** for the words, a tile shape and one
letter face. The small grey line under each board shows the checks the page runs while it builds: letter contrast on the
tiles, the smallest colour difference (ΔE) between two tiles, and how far apart the three word colours are.

**How I picked them.** I started over, with three rules. Each person had to have made things for children, or made
things children love. Their look had to survive being reduced to a palette, a shape and a typeface. And the list had to
travel: Italy, France and Japan as Pietro asked, then Germany, Sweden, the US, Canada, Mexico, Brazil, South Africa and
India. Eight of the twenty are women. I borrowed only principles (palettes, shapes, edges, type), never characters or motifs.

**About the galleries.** Published claude.ai pages can't load images from other sites, and most of these works are still
under copyright. So each gallery card is a small abstract sketch made from the style's own palette, as a reminder only.
Tap a card to open an image search for the real work, or "about" for its page.
"""

var toc = """<ul class="toc">"""
for i, st in styles: toc &= &"""<li><a href="#{st.id}">{i + 1:02} {st.name.replace(" and Memphis", "")}</a></li>"""
nbRawHtml: toc & "</ul>"

var problems: seq[string]
for i, st in styles:
  let a = audit(st)
  if a.ink < 4.5: problems.add &"{st.id}: letter contrast {a.ink:.2f}"
  if a.wordsOnCard < 4.5: problems.add &"{st.id}: word colour contrast on card {a.wordsOnCard:.2f}"
  if a.words < 25: problems.add &"{st.id}: word colours too close (ΔE {a.words:.1f})"
  if a.tiles < 10: problems.add &"{st.id}: tiles too close (ΔE {a.tiles:.1f})"
  var links = """<ul class="links">"""
  for l in st.links: links &= &"""<li><a href="{l.url}" target="_blank" rel="noopener">{l.label} ↗</a></li>"""
  links &= "</ul>"
  nbRawHtml: &"""
</main><section class="st" id="{st.id}" data-skin="{st.id}">
<h2><span class="n">{i + 1:02} / 20 · {st.flag} {st.place}</span>{st.name}</h2>
<p class="sub">{st.role} · {st.life}</p>
<div class="play">{cluesHtml(st)}{playSvg(st)}</div>
<p class="checks">letters {a.ink:.1f}:1 · tiles ΔE ≥ {int(a.tiles)} · words ΔE ≥ {int(a.words)}, {a.wordsOnCard:.1f}:1 · {st.font}</p>
<div class="insp">
<h3>Who</h3><p>{st.who}</p>
<p class="took"><b>What I took.</b> {st.took}</p>
<p><b>Why for Parloku.</b> {st.why}</p>
{links}
{galleryHtml(st)}
<details class="css"><summary>this style as game CSS</summary><pre>{skinCss(st)}</pre></details>
</div></section><main>"""

if problems.len > 0:
  echo "colour checks:\n  " & problems.join("\n  ")

nbText: """
## Where next

The variables are the ones the game is moving to (`--g0`…`--g5` for the letters, `--w0`…`--w2` for the words, plus the
ground, card and board tints), so any of the twenty can become a game skin by pasting its CSS block. The tile shapes need
a few more SVG shapes in the game than the three it draws today: a blob, an arch, a nested square, a ring and a dashed fill.

If I had to pick five to try in the real game first: **Kusama** (the board really is a white room you fill with dots),
**Albers** (colour is the information), **Anno** (logic for children), **Mahlangu** (the most readable), and **Morandi**
(the calm one for grown-ups).
"""

nbRawHtml: "</main>"
nbSave
