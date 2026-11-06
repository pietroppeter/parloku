## The spiega page: give it any puzzle (`spiega.html?p=<code>`, the code of a play link) and it explains it step by
## step, live in the browser, with the step solver (src/stepsolver.nim) and the gallery of the devlog post
## "A puzzle, step by step" (src/stepsview.nim). Without a code it lists the puzzles in data/. Writes spiega.html.
import std/[json, os, strutils, strformat, algorithm, sequtils]
import nimib
import style, stepsview

let root = currentSourcePath().parentDir.parentDir

# the puzzles in data/, as links to this page
var list = ""
var files: seq[string]
for f in walkFiles(root / "data" / "puzzle*.json"): files.add f
files.sort(proc (a, b: string): int = cmp(a.extractFilename.strip(chars = Letters).split('-')[0].parseInt,
  b.extractFilename.strip(chars = Letters).split('-')[0].parseInt))   # by number: puzzle10 after puzzle9
for f in files:
  let j = parseFile(f)
  let p = j["problem"]
  let letters = p["letters"].getElems.mapIt(it.getStr).join
  let givens = p["letterHints"].getElems.mapIt(&"""{it["pos"][0].getInt}{it["pos"][1].getInt}{it["letter"].getStr}""").join(".")
  let words = p["wordHints"].getElems.mapIt(&"""{it["pos"][0].getInt}{it["pos"][1].getInt}{it["word"].getStr}""").join(".")
  let title = p["wordHints"].getElems.mapIt(it["word"].getStr).join(" · ")
  list.add &"""<li><a href="?p={letters}_{givens}_{words}">{title}</a></li>"""

const pageCss = """
<style>
.kicker{font:700 .72rem/1.2 var(--font-body,sans-serif);letter-spacing:.12em;text-transform:uppercase;color:var(--muted);margin:1.6rem 0 .3rem}
.sum{background:var(--card);border:1.5px solid var(--line);border-radius:14px;padding:8px 14px;margin:12px 0;font-size:15px}
.sum.stuck{border-color:#e06666}
.puzzles{padding-left:1.2em}
.code{width:100%;font:15px "JetBrains Mono",monospace;padding:8px;border:1.5px solid var(--line);border-radius:10px;box-sizing:border-box}
</style>
"""

nbInit
nb.doc.filename = root / "spiega.html"
nb.doc.context["title"] = %"Parloku · spiega un puzzle"
nb.doc.context["stylesheet"] = %(pageStyle & "<style>" & galleryCss & "</style>" & pageCss)
nb.doc.context["highlight"] = %""
nb.doc.context["disableHighlightJs"] = %true
func pageHeader(blk: JsonNode, nb: Nb): string =
  """<header><span><a href="./">parloku</a> · spiega</span><span><a href="builder.html">builder</a></span></header>"""
nb.backend.partials["header"] = pageHeader

nbRawHtml: &"""
<p class="kicker">SPIEGA</p>
<h1 id="title">Un puzzle, passo per passo</h1>
<div id="out"></div>
<div id="pick">
<p>Scegli un puzzle, oppure incolla il codice o il link di un puzzle (quello del 🔗 del builder):</p>
<ul class="puzzles">{list}</ul>
<form id="form"><input class="code" id="code" name="p" placeholder="AELOPR_54A.51E.25A_43PAROLE.32PERLE.21OPERA" autocomplete="off"></form>
</div>
<p class="hint" id="hint" hidden>← scorri o tocca →</p>
"""

nbJsFromCode:
  import std/[dom, strutils, sequtils, strformat]
  import solver, stepsolver, stepsview

  proc search(): cstring {.importjs: "(location.search)@".}
  proc decodeUri(s: cstring): cstring {.importjs: "decodeURIComponent(#)".}
  proc scrollByX(e: Element, dx: float) {.importjs: "#.scrollBy({left: #, behavior: 'smooth'})".}
  proc scrollToStart(e: Element) {.importjs: "#.scrollTo({left: 0, behavior: 'smooth'})".}
  proc left(e: Element): float {.importjs: "#.getBoundingClientRect().left".}
  proc width(e: Element): float {.importjs: "#.getBoundingClientRect().width".}
  proc clientX(e: Event): float {.importjs: "#.clientX".}
  proc scrollLeftF(e: Element): float {.importjs: "#.scrollLeft".}
  proc scrollWidthF(e: Element): float {.importjs: "#.scrollWidth".}

  proc codeOf(q: string): string =
    ## the p= value of a query string or a whole link, or the code itself
    result = q.strip(chars = {'?', '#', ' '})
    let at = result.find("p=")
    if at >= 0:
      result = result[at + 2 .. ^1]
      let amp = result.find('&')
      if amp >= 0: result = result[0 ..< amp]
    result = result.toUpperAscii

  proc explain(code: string) =
    let parts = code.split('_')
    let outEl = document.getElementById("out")
    if parts.len != 3 or parts[0].len != 6:
      outEl.innerHTML = cstring("""<div class="sum stuck">Questo codice non è un puzzle.</div>""")
      return
    var e = Explained(id: "gal", letters: parts[0], ends: true)
    var pr: Problem
    for i, ch in parts[0]: pr.letters[i] = ch
    var givens: seq[(int, char)]
    for item in parts[1].split('.'):
      if item.len >= 3 and item[0] in '0'..'5' and item[1] in '0'..'5':
        let c = (ord(item[0]) - ord('0')) * 6 + ord(item[1]) - ord('0')
        givens.add (c, item[2])
        pr.letterHints.add HintLetter(pos: coordOf(c), letter: item[2])
    for item in parts[2].split('.'):
      if item.len >= 3 and item[0] in '0'..'5' and item[1] in '0'..'5':
        let c = (ord(item[0]) - ord('0')) * 6 + ord(item[1]) - ord('0')
        e.words.add item[2 .. ^1]
        e.starts.add c
        pr.wordHints.add HintWord(pos: coordOf(c), word: item[2 .. ^1])
    e.givens = givens.mapIt(it[0])
    if validate(pr).len > 0 or e.words.len == 0:
      outEl.innerHTML = cstring("""<div class="sum stuck">Questo codice non è un puzzle valido.</div>""")
      return
    document.getElementById("title").innerHTML = cstring(e.words.join(" · ") & ", passo per passo")
    let r = solve(pr, defaultOptions(limit = 2, keep = 1))
    if r.count == 0:
      outEl.innerHTML = cstring("""<div class="sum stuck">Questo puzzle non ha soluzione.</div>""")
      return
    if r.count == 1:
      for row in r.solutions[0]:
        for ch in row: e.solution.add ch
    e.steps = explainSteps(e.letters, givens, e.words, e.starts)
    var moves: seq[string]
    let follow = e.steps.countIt(it.kind in ["follow", "wordpaths"])
    let look = e.steps.countIt(it.kind in ["follow", "wordpaths"] and ("Resta" in it.text or "tutti i modi" in it.text))
    let hidden = e.steps.countIt(it.kind == "hidden")
    let other = e.steps.countIt(it.kind in ["naked", "wordpoint", "pointing"])
    moves.add &"{follow} segui la parola ({look} guardando avanti)"
    moves.add &"{hidden} unico posto"
    if other > 0: moves.add &"{other} altre mosse"
    let play = &"""<a href="https://pietroppeter.github.io/parloku/?p={code}">gioca</a>"""
    var sum: string
    if r.count > 1:
      sum = &"""<div class="sum stuck">Attenzione: questo puzzle ha più di una soluzione. Il risolutore si ferma dove serve una scelta. · {play}</div>"""
    elif e.steps.solved:
      sum = &"""<div class="sum">Si risolve senza tentativi in {e.steps.len - 1 - e.words.len} mosse: """ &
        moves.join(", ") & &""". · {play}</div>"""
    else:
      sum = &"""<div class="sum stuck">Il risolutore si ferma al passo {e.steps.len - 1}: da lì serve un tentativo (o una mossa che non conosce). · {play}</div>"""
    outEl.innerHTML = cstring(sum & e.gallery)
    document.getElementById("pick").setAttr("hidden", "")
    document.getElementById("hint").removeAttribute("hidden")
    let gal = document.getElementById("gal")
    gal.addEventListener("click", proc (ev: Event) =
      let step = gal.querySelector(".sl").width + 16
      if ev.clientX - gal.left < gal.width * 0.3: gal.scrollByX(-step)
      elif gal.scrollLeftF + gal.width >= gal.scrollWidthF - 4: gal.scrollToStart()
      else: gal.scrollByX(step))

  let code = codeOf($decodeUri(search()))
  if code.len > 0: explain(code)
  # the list of puzzles explains in place, without loading the page again (an artifact preview has no query string)
  for a in document.querySelectorAll(".puzzles a"):
    let link = a
    link.addEventListener("click", proc (ev: Event) =
      ev.preventDefault()
      explain(codeOf($link.getAttribute("href"))))
  document.getElementById("form").addEventListener("submit", proc (ev: Event) =
    ev.preventDefault()
    let v = codeOf($document.getElementById("code").value)
    if v.len > 0: explain(v))

nbSave
