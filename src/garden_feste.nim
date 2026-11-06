## Garden page: le feste, the dances the letters do when a puzzle is solved. A living page: each dance is played by the
## game itself (an iframe of index.html with ?party=), on a board with one letter left to place.
## Writes garden/feste/index.html. Add a dance here when the game gets a new one.
import std/[json, os, strformat, strutils]
import nimib
import style

let root = currentSourcePath().parentDir.parentDir

nbInit
nb.doc.filename = root / "garden" / "feste" / "index.html"
nb.doc.context["title"] = %"Parloku · le feste"
nb.doc.context["stylesheet"] = %(pageStyle & """
<style>
html{-webkit-text-size-adjust:100%;text-size-adjust:100%}
.kicker{font:700 .72rem/1.2 var(--font-body,sans-serif);letter-spacing:.12em;text-transform:uppercase;color:var(--muted);margin:1.6rem 0 .3rem}
.dance{background:var(--card);border:var(--border) solid var(--line);border-radius:16px;padding:12px 14px;margin:18px 0}
.dance h2{font-size:24px;margin:4px 0 6px}
.dance h2 .em{font-size:1.1em;margin-right:.25em}
.dance p{margin:6px 0;line-height:1.45}
.dance .do{font-weight:600}
.try{margin:10px -4px 2px;display:flex;flex-direction:column;align-items:center;gap:6px}
.try iframe{width:min(100%,330px);height:600px;border:var(--border) solid var(--line);border-radius:14px;background:var(--bg)}
.again{font:700 14px var(--font-body);border:var(--border) solid var(--ink);background:var(--card);color:var(--ink);border-radius:999px;padding:5px 14px;cursor:pointer}
.note{color:var(--muted);font-size:15px}
</style>""")
nb.doc.context["highlight"] = %""
nb.doc.context["disableHighlightJs"] = %true
func pageHeader(blk: JsonNode, nb: Nb): string =
  """<header><span><a href="../../">parloku</a> · <a href="../../devlog/">devlog</a> · garden</span><span>living page</span></header>"""
nb.backend.partials["header"] = pageHeader

const code = "AILPST_51S.23L.04P_00ITALIA.20PASTA.40ALPI"   # puzzle 1, ITALIA · PASTA · ALPI
const solution = "ITASPLSPLIATPASLTILITASPALPTISTSIPLA"
proc board(missing: int): string =
  ## the solved board as &g= letters, but for one empty cell
  var items: seq[string]
  for c in 0 ..< 36:
    if c != missing: items.add &"{c}{solution[c]}"
  items.join(",")
proc cellName(c: int): string = &"r{c div 6 + 1}c{c mod 6 + 1}"

type Dance = tuple[key, emoji, name, how: string, missing: int]
let dances: seq[Dance] = @[
  ("wave", "🌊", "Onda: ripples", "Ripples spread from the last letter you place, like a stone dropped in a pond: three " &
   "crests, two cells apart, that grow smaller as they travel. Each letter rises and dips as a crest goes by.", 14),
  ("snakes", "🐍", "Serpenti: the words", "The three words dance one after another, in the order of the clues: each " &
   "letter hops after the one before it, like a snake, tilting left and right. Then every letter on the board hops once.", 35),
  ("letters", "🪀", "Lettere: the sudoku", "All six copies of a letter jump and spin together, one letter after another, " &
   "like yo-yos: you see that each letter is once in every row, column and box. Then everyone jumps.", 0),
]

nbRawHtml: """<script>document.body.dataset.skin = 'niki'</script>
<p class="kicker">GARDEN · A LIVING PAGE</p>
<h1>Le feste</h1>
<p class="lede">When the last letter solves the grid, the letters on the board dance for about three seconds, letter
confetti falls, and then <b>Evviva! 🥳</b> pops up below the grid. Each win picks one of these dances at random.</p>
<p class="note">Try each one: put the last letter on the board below it (a double tap on the empty cell fills it), and
↺ starts again. The emoji is the one the share line will use for that dance.</p>
"""

for d in dances:
  nbRawHtml: &"""<section class="dance" id="{d.key}"><h2><span class="em">{d.emoji}</span>{d.name}</h2>
<p>{d.how}</p>
<p class="do">The empty cell is {cellName(d.missing)}.</p>
<div class="try"><iframe loading="lazy" src="../../index.html?nosplash&amp;demo&amp;party={d.key}&amp;p={code}&amp;g={board(d.missing)}" title="{d.name}"></iframe><button class="again" type="button">↺ da capo</button></div>
</section>"""

nbRawHtml: """<p class="note">How they are drawn: every frame, each letter on the board gets an SVG transform (a move, a
turn, a scale), as the restless marbles do, so the dances look the same on iPhone Safari and in Chrome. With reduced
motion the letters stay still. A board that was already solved shows Evviva! at once, with no dance.
The code is <code>celebrate</code> in <code>src/parloku.nim</code>; the behaviour is in the <a href="../../specs/">specs</a>
(player · Winning).</p>"""

nbJsFromCode:
  import std/dom
  proc frameOf(e: Element): Element {.importjs: "#.closest('.try').querySelector('iframe')".}
  proc reload(f: Element) {.importjs: "(f => { f.src = f.src })(#)".}
  proc onHeight(cb: proc (f: Element, h: float)) {.importjs:
    "(cb => addEventListener('message', ev => { const h = ev.data && ev.data.parlokuHeight; if (!h) return; " &
    "for (const f of document.querySelectorAll('.try iframe')) if (f.contentWindow === ev.source) cb(f, h) }))(#)".}
  proc setHeight(f: Element, h: float) {.importjs: "#.style.height = # + 'px'".}
  # each board as tall as its game (the game in the frame says how tall it is), and a little more for the banner
  onHeight(proc (f: Element, h: float) = f.setHeight(h + 24))
  for b in document.querySelectorAll(".try .again"):
    b.addEventListener("click", proc (ev: Event) =
      let f = Element(ev.currentTarget).frameOf
      f.reload)

nbSave
