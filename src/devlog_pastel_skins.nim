## Devlog post: ten pastel skins for Parloku. Embeds the game as built in ../index.html (build that first),
## explains each skin when it is selected, and audits every skin's colours while the page builds.
import std/[json, os, re, strutils, strformat, math, sequtils, tables]
import nimib
import style

const devlogStyle = """
<style>
.kicker{font:700 .72rem/1.2 var(--font-body,sans-serif);letter-spacing:.12em;text-transform:uppercase;color:var(--muted);margin:1.6rem 0 .3rem}
.about{margin:1.4rem auto;max-width:640px}
.about article{background:var(--card);border:var(--border,2px) solid var(--line);border-radius:18px;padding:1rem 1.2rem;box-shadow:var(--shadow,none)}
.about article h3{margin:.1rem 0 .5rem;font-family:var(--font-head)}
.about article .kicker{margin-top:0}
.about dl{margin:.6rem 0;display:grid;grid-template-columns:auto 1fr;gap:.3rem .8rem}
.about dt{font-weight:700;color:var(--ink)}
.about dd{margin:0}
.measure{font:600 .8rem/1.4 ui-monospace,Menlo,monospace;color:var(--muted);margin:.6rem 0 0}
.tablewrap{overflow-x:auto;-webkit-overflow-scrolling:touch}
table.audit{border-collapse:collapse;font-size:.85rem;width:100%;min-width:480px}
table.audit th,table.audit td{padding:.35rem .5rem;border-bottom:1px solid var(--line);text-align:right}
table.audit th:first-child,table.audit td:first-child{text-align:left}
table.audit td.bad{color:#b00020;font-weight:700}
</style>
"""

let root = currentSourcePath().parentDir.parentDir

nbInit
nb.doc.filename = root / "devlog" / "pastel-skins" / "index.html"
nb.doc.context["title"] = %"Parloku devlog · ten skins"
nb.doc.context["stylesheet"] = %(pageStyle & devlogStyle)
nb.doc.context["highlight"] = %""
nb.doc.context["disableHighlightJs"] = %true
func pageHeader(blk: JsonNode, nb: Nb): string =
  """<header><span><a href="../../">parloku</a> · devlog</span><span>04 Nov 2026</span></header>"""
nb.backend.partials["header"] = pageHeader

# ---- the game, as built: only the playing parts of ../index.html
let built = readFile(root / "index.html")
proc slice(s, start, stop: string): string =
  let a = s.find(start)
  let b = s.find(stop, a)
  doAssert a >= 0 and b > a, "index.html is missing " & start & ": build src/parloku.nim first"
  s[a ..< b]
let skinsRow = slice(built, """<div class="skins"""", "\n")
let game = slice(built, """<div class="game">""", """<div class="rules">""")
let builtinList = slice(built, """<template id="builtin">""", "\n")
let gameScript = slice(built, "<script>", "</script>") & "</script>"

nbRawHtml: """
<p class="kicker">DEVLOG · 01</p>
<h1>Ten skins for a letter game</h1>
<p class="lede">Pietro asked for a Parloku that is less cluttered, in pastel colours, that his seven-year-old daughter would like
and grown-ups would still find beautiful. Instead of guessing one answer, here are ten, each after an artist or a tradition.
Pick one below and play; the notes under the board change with it.</p>
""" & skinsRow & game & builtinList

nbRawHtml: """<div class="about" id="about"></div>"""

# ---- the colour audit, computed here at build time from the same CSS the page uses
nbRawHtml: """<h2><span class="num">01 · WHY THESE TEN</span>How I picked the artists</h2>"""

nbText: """
I started from the request rather than from a list of favourite artists. Three filters:

1. **They made things for children, or children love what they made.** Munari, Tullet, Lionni, Bruna and Taro Gomi
   are picture-book makers first. Miró, Matisse, Delaunay and Maija Isola are not, but their work is what children draw
   when you hand them scissors and paint: dots, stars, blobs, bold flowers.
2. **Their style is made of a few rules, not of pictures.** A Parloku skin only has six tile colours, six letter colours,
   one tile shape, one kind of line, one texture and three typefaces. An artist whose look survives being reduced to that
   (Munari's square and circle, Bruna's black outline, Delaunay's rings, Lionni's torn paper) translates; one whose look
   lives in drawing characters or scenes does not. That is also the line I didn't cross: no characters, no copied motifs,
   no rabbit. Only palettes, shapes, edges and type, borrowed as principles.
3. **A spread of places**, as Pietro asked: Italy, France, Spain, the Netherlands, Finland and Japan.

One of the ten isn't a person. *Wagashi* are Japanese seasonal sweets; their palette (sakura pink, matcha, yuzu, chestnut)
is one of the gentlest I know, and I wanted one skin that is calm rather than loud. The old maiolica look stays as an
eleventh option, for comparison.
"""

nbRawHtml: """<h2><span class="num">02 · ANATOMY</span>What a skin is made of</h2>"""

nbText: """
Before, colours were written into the Nim code that draws the board. Now the Nim view only names things: a tile is a group
with class `g3` holding three shapes (`sq`, `rd`, `ci`); a cell is `cell ca`; a word path is `wp c1`. A skin is a block of CSS
that answers every name. These are all the elements a skin decides:

- **Ground and ink:** the page background, the card behind the board, the text colour and a muted text colour.
- **Six tile colours and six letter colours** (`--g0`…`--g5`, `--i0`…`--i5`), one pair per letter.
- **Five clue inks** (`--c0`…`--c4`) for the numbered markers, the word paths and the chips above the board.
- **Tile shape:** square, rounded, round, or alternating by letter. All three shapes are drawn and CSS shows one, so changing
  shape costs nothing at runtime.
- **Line:** the tile outline (none, hairline, or a thick black contour) and the board's box lines.
- **Texture:** an SVG filter that roughens edges, either finely (pencil, torn paper) or coarsely (scissors).
- **Board:** frame, the two alternating cell tints, the clash and tutorial highlights.
- **Type:** heading, body and letter typefaces, and the weight of the letters.
- **Furniture:** card radius, borders, shadows. Most skins drop shadows altogether.

Here is the whole Tullet skin, to show how little it takes:

```css
[data-skin=tullet]{
  --bg:#ffffff; --g0:#ff8a80; --g1:#ffd86b; --g2:#7fb3ff; --g3:#ffb26b; --g4:#8fd694; --g5:#c29bea;
  --i0:#1f1f1f; ... --c0:#d0353a; --c1:#1f63c4; ...
  --frame:#1f1f1f; --font-glyph:Fredoka,sans-serif; --glyph-weight:600;
}
[data-skin=tullet] .tile .rd{display:none}
[data-skin=tullet] .tile .ci{display:inline}
```
"""

nbRawHtml: """<h2><span class="num">03 · PRINCIPLES</span>How I judge if a skin works</h2>"""

nbText: """
"Less cluttered" and "more playful" are taste, but most of what makes them work can be checked. I used five principles:

1. **Every letter must be easy to read on its tile.** Letter against tile contrast of at least 4.5:1, the WCAG level for
   normal text, even though the letters are big and bold (where 3:1 would already pass).
2. **Every tile must be told apart from the others and from the board.** Colour distance ΔE of at least 15 between any two
   tile colours, and between a tile and the cell it sits on, unless the skin draws an outline.
3. **Information keeps its colour; decoration loses it.** Clue numbers, word paths and muted text get at least 4.5:1, so the
   things you need while playing never fade. The decoration that carried no information went: the patterned band, the hard
   shadows and the row/column labels (now shown only during the tutorial, where the hints name cells).
4. **One idea per skin.** One shape rule, one line rule, at most one texture. If a skin needs two tricks, it is cluttered.
5. **Playful means soft edges and a light ground.** Round or hand-made shapes, warm or white backgrounds, friendly type.
   The test is squinting at a phone screenshot: you should see six soft colours and the letters, nothing else.

The first two and the third are numbers, so the page measures them while it builds, straight from the CSS you are looking at:
"""

nbCode:
  type Rgb = tuple[r, g, b: float]
  proc hex(s: string): Rgb =
    var h = s.strip.strip(chars = {'#'})
    if h.len == 3: h = h.mapIt($it & $it).join
    (parseHexInt(h[0..1]) / 255, parseHexInt(h[2..3]) / 255, parseHexInt(h[4..5]) / 255)
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

  # every skin's variables, read from the page's own stylesheet
  proc vars(body: string): Table[string, string] =
    for m in body.findAll(re"--[\w-]+:[^;]+;"):
      let kv = m[2 .. ^2].split(':', 1)
      result[kv[0]] = kv[1].strip
  let base = vars(pageStyle.split(":root,[data-skin=munari]{")[1].split("\n}")[0])
  var skins: OrderedTable[string, Table[string, string]]
  for (id, label, flag) in skinList:
    var v = base
    let marker = "\n[data-skin=" & id & "]{"
    if marker in pageStyle:
      for k, x in vars(pageStyle.split(marker)[1].split("\n}")[0]): v[k] = x
    skins[id] = v

  type Audit = object
    letters, tiles, onBoard, clues, muted: float
    outlined: bool
  var audits: OrderedTable[string, Audit]
  for id, v in skins:
    var a = Audit(letters: Inf, tiles: Inf, onBoard: Inf, clues: Inf)
    for k in 0 .. 5:
      a.letters = min(a.letters, contrast(v[&"g{k}"], v[&"i{k}"]))
      a.onBoard = min(a.onBoard, deltaE(v[&"g{k}"], v["ca"]))
      for j in k + 1 .. 5: a.tiles = min(a.tiles, deltaE(v[&"g{k}"], v[&"g{j}"]))
    for k in 0 .. 4: a.clues = min(a.clues, min(contrast(v[&"c{k}"], v["card"]), contrast(v[&"c{k}"], "#ffffff")))
    a.muted = contrast(v["muted"], v["bg"])
    a.outlined = v["tstroke"] != "none"
    audits[id] = a

  proc mark(ok: bool): string = (if ok: "✓" else: "✗")
  var table = """<table class="audit"><tr><th>skin</th><th>letter on tile</th><th>tile vs tile</th>""" &
    """<th>tile vs board</th><th>clue inks</th><th>muted text</th></tr>"""
  for (id, label, flag) in skinList:
    let a = audits[id]
    let board = if a.outlined: "outlined" else: &"ΔE {int(round(a.onBoard))} {mark(a.onBoard >= 15)}"
    table.add &"""<tr><td>{label} {flag}</td><td>{a.letters:.1f}:1 {mark(a.letters >= 4.5)}</td>""" &
      &"""<td>ΔE {int(round(a.tiles))} {mark(a.tiles >= 15)}</td><td>{board}</td>""" &
      &"""<td>{a.clues:.1f}:1 {mark(a.clues >= 4.5)}</td><td>{a.muted:.1f}:1 {mark(a.muted >= 4.5)}</td></tr>"""
  table.add "</table>"
  let failing = toSeq(audits.pairs).filterIt(it[1].letters < 4.5 or it[1].tiles < 15 or it[1].clues < 4.5 or
    it[1].muted < 4.5 or (not it[1].outlined and it[1].onBoard < 15)).mapIt(it[0])
  echo &"{skins.len} skins audited, {failing.len} failing: {failing}"

nbRawHtml: "<div class=\"tablewrap\">" & table & "</div>"

nbRawHtml: """<h2><span class="num">04 · WHAT THE AUDIT CAUGHT</span>Fixes made while writing this</h2>"""

nbText: """
Writing the principles down and measuring them turned up real problems in the first version of the skins, all fixed
in this one:

- **White letters on pastel tiles.** Tullet's blue, Miró's blue, Matisse's blue and one maiolica glaze had white letters
  at 2.1 to 3.3:1. Pastel and white text never work together; those letters are now dark, and Matisse's blue is a deeper
  cobalt so its white letter reaches 5.8:1.
- **Yellow and orange clue inks.** Every skin had a sunny clue colour at about 2:1 on white, which made a word path and its
  white number hard to see. All clue inks are now darker versions of the same hue, at 4.6:1 or more.
- **Muted text** (stats, empty clue letters, "show machinery") was 2.7 to 3.6:1. It is now at least 4.6:1.
- **Two wagashi tiles were twins** (sakura and azuki, ΔE 13). Azuki became chestnut.
- **Motion.** The pulsing tutorial target and the confetti now stop when the device asks for reduced motion, and buttons get a
  visible keyboard focus ring.

What the audit can't fix, and is still open:

- **Small cells on phones.** On a 390 px screen a cell is about 35 px, under the 44 px usually advised for touch.
  Snapping makes drops forgiving, but a phone layout with less margin around the board would help.
- **The board isn't keyboard-playable yet.** Tiles can only be dragged; a tap-a-stack, tap-a-cell mode would serve both
  keyboards and small fingers.
- **Textured skins cost more.** Lionni, Gomi and Matisse run an SVG filter on every tile; fine on a recent phone,
  worth checking on an old one.
- **Fonts come from Google Fonts.** Offline, each skin falls back to a system face, which flattens the hand-made ones.
"""

nbRawHtml: """<h2><span class="num">05 · NEXT</span>Choosing</h2>"""

nbText: """
The real test of "something a seven-year-old might like" is a seven-year-old. Play a few boards in each skin and
keep the two or three that survive. The winners become the default, and the rest go back in the drawer.
"""

# ---- the per-skin notes shown under the board
let notes = {
  "munari": ("Bruno Munari", "Italy · 1907–1998",
    "Designer, artist and maker of books for children who taught that <i>complicating is easy, simplifying is hard</i>. His little books <i>Il quadrato</i>, <i>Il cerchio</i> and <i>Il triangolo</i> treat basic shapes as characters, and his children's workshops at the Brera gallery in Milan let children learn by playing.",
    "White space, no outlines, and the square and the circle taking turns: odd letters are discs, even letters are squares. Soft primary and secondary colours with dark letters.",
    "The calmest of the ten. The alternating shapes add play without adding anything to read."),
  "tullet": ("Hervé Tullet", "France · born 1958",
    "Author of <i>Un livre</i> (<i>Press Here</i>, 2010): a book of red, yellow and blue dots that you press, shake and tilt. In <i>Say Zoop!</i> the dots and lines make sounds. He calls himself an illustrator of the reader's imagination.",
    "Everything is a big round dot on white, led by red, yellow and blue, with a single black frame. A rounded, friendly typeface.",
    "Probably the most child-friendly of the ten: it looks like a page from his books waiting to be pressed."),
  "lionni": ("Leo Lionni", "Italy and the USA · 1910–1999",
    "Born in Amsterdam, he lived and worked in Italy and America. <i>Little Blue and Little Yellow</i> (1959) began as torn paper on a train with his grandchildren; <i>Swimmy</i> and <i>Frederick</i> followed.",
    "Tiles with torn-paper edges (an SVG turbulence filter), soft blues, yellows and greens, a handwritten face, and pale lines that recede.",
    "Warm and handmade. The rough edges are the one trick, so the board stays quiet."),
  "miro": ("Joan Miró", "Spain · 1893–1983",
    "The Catalan painter of black lines, stars and floating spots of pure colour. Children recognise his world instantly, and he said he wanted to paint like a child.",
    "A cream ground, a black contour on every tile, discs and rounded squares taking turns, and one black tile with a yellow letter like a Miró spot.",
    "The boldest of the pastels. The black tile is a deliberate accent; it is also the one place the palette stops being pastel."),
  "gomi": ("Taro Gomi", "Japan · born 1945",
    "Author of hundreds of picture books, from <i>Everyone Poops</i> to his doodle books that leave half the page for the child to finish. His line is loose, warm and never ruled.",
    "Wobbly brown outlines and wobbly box lines (the same filter as Lionni, applied to the line instead of the paper), sunny colours, a handwritten heading.",
    "Playful, but the most decorated: the wobbly box lines are on the edge of clutter. A candidate for keeping straight lines."),
  "wagashi": ("Wagashi", "Japan · a tradition",
    "Not an artist but Japanese confectionery, where colours follow the season: sakura pink in spring, matcha green, yuzu yellow, chestnut in autumn.",
    "Muted pastels with coloured letters instead of black, rounded squares with no outline, a large radius everywhere and Zen Maru Gothic, a rounded Japanese typeface.",
    "The quietest skin, for grown-ups who want calm. Less exciting for a child."),
  "delaunay": ("Sonia Delaunay", "France · 1885–1979",
    "Born in Ukraine, she worked in Paris with Robert Delaunay on <i>simultanism</i>: colours set side by side so they vibrate. Her discs of concentric colour ran through paintings, fabrics, costumes and even cars.",
    "Round tiles with an inner ring, bright pastels from peach to lilac, a geometric typeface.",
    "Lively without lines. The ring is the one idea, and it reads like a sweet or a target, which children like."),
  "bruna": ("Dick Bruna", "The Netherlands · 1927–2017",
    "The Utrecht designer behind more than a hundred small square books. He drew with a handful of flat colours, always inside a thick black line, and removed everything else.",
    "Flat colour, a thick black outline on every tile and on the board, square tiles. Nothing else.",
    "The clearest board of all, and the strongest outline. Square tiles feel a little less playful than round ones."),
  "matisse": ("Henri Matisse", "France · 1869–1954",
    "In his last years, unable to paint standing, he cut shapes from paper he had painted with gouache: <i>Jazz</i>, <i>The Snail</i>, the blue nudes. He called it drawing with scissors.",
    "Cobalt, coral, leaf green and lemon on warm white, tiles with scissor-cut edges (a coarse filter), a serif face.",
    "The most grown-up of the ten. The cut edges are subtle on a small screen."),
  "isola": ("Maija Isola", "Finland · 1927–2001",
    "Designer of many of Marimekko's prints, including the giant <i>Unikko</i> poppy of 1964, drawn when the company said it would never print flowers.",
    "Big round tiles with a black outline, fresh pastels, a modern grotesque typeface, white everywhere else.",
    "Bold and clean. With Tullet, the one I'd show a child first."),
  "maiolica": ("Maiolica", "Italy · the first look",
    "The original Parloku skin: tin-glazed Italian pottery, cobalt ink and saturated glazes.",
    "Glazed rounded tiles with a shine, cobalt outlines, a serif face, hard offset shadows.",
    "Kept for comparison. It is exactly what the new skins move away from: more lines, more shadow, darker colours."),
}.toTable

var notesHtml = ""
for (id, label, flag) in skinList:
  let (who, where, bio, took, verdict) = notes[id]
  let a = audits[id]
  notesHtml.add &"""<article data-about="{id}" hidden><p class="kicker">{flag} {where}</p><h3>{who}</h3><p>{bio}</p>""" &
    &"""<p><b>What I borrowed.</b> {took}</p><p><b>Verdict.</b> {verdict}</p>""" &
    &"""<p class="measure">letters {a.letters:.1f}:1 · closest tiles ΔE {int(round(a.tiles))} · clue inks {a.clues:.1f}:1</p></article>"""
nbRawHtml: "<template id=\"notes\">" & notesHtml & "</template>"

nbRawHtml: gameScript
nbRawHtml: """<script>
// show the notes for the selected skin, under the board
(function () {
  const about = document.getElementById('about');
  about.innerHTML = document.getElementById('notes').innerHTML;
  const show = () => about.querySelectorAll('article').forEach(a => a.hidden = a.dataset.about !== document.body.dataset.skin);
  new MutationObserver(show).observe(document.body, {attributes: true, attributeFilter: ['data-skin']});
  show();
})();
</script>"""

nbSave
