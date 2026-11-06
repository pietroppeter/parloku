## The daily splash and the first lesson, in the browser. Compiled to JavaScript with the game's script
## (src/parloku.nim imports it), so it is the same Nim as the rest. The page markup and style are in src/splash.nim.
##
## The overlay `<div id="splash">` carries the lesson's puzzle in data attributes. Without it (the devlog posts
## that don't show the splash) nothing happens. With `data-manual` nothing opens by itself, and the page calls
## `parlokuSplash.splash(first)`, `.lesson()` or `.lineFor(date)`.
##
## URL switches: `?splash=first` shows the first-visit splash again, `?learn` opens the lesson directly,
## `?nosplash` skips it (and so does `?tutorial`), `?day=2026-12-25` previews another day.
import std/[dom, asyncjs, strutils, strformat, sequtils]

type
  JsDate = ref object of JsRoot
  Stop = object of CatchableError
  Clue = object
    word: string
    r, c: int
    path: seq[int]

proc newDate(): JsDate {.importjs: "new Date()".}
proc newDate(y, m, d, h: int): JsDate {.importjs: "new Date(#, #, #, #)".}
proc hours(d: JsDate): int {.importjs: "#.getHours()".}
proc month(d: JsDate): int {.importjs: "(#.getMonth() + 1)".}
proc day(d: JsDate): int {.importjs: "#.getDate()".}
proc dayNumber(d: JsDate): int {.importjs: "(d => Math.floor(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()) / 864e5))(#)".}
proc longDate(d: JsDate, loc: cstring): cstring {.importjs: "#.toLocaleDateString(#, {weekday: 'long', day: 'numeric', month: 'long'})".}
proc weekday(d: JsDate, loc: cstring): cstring {.importjs: "#.toLocaleDateString(#, {weekday: 'long'})".}
proc search(): cstring {.importjs: "String(location.search)".}
proc docLang(): cstring {.importjs: "String(document.documentElement.lang)".}
proc lsGet(k: cstring): cstring {.importjs: "(k => { try { return localStorage.getItem(k) } catch (e) { return null } })(#)".}
proc lsSet(k, v: cstring) {.importjs: "((k, v) => { try { localStorage.setItem(k, v) } catch (e) {} })(#, #)".}
proc lessMotion(): bool {.importjs: "matchMedia('(prefers-reduced-motion: reduce)').matches".}
proc nextFrame(cb: proc (t: float)) {.importjs: "requestAnimationFrame(#)".}
proc attr(e: Element, k: cstring): cstring {.importjs: "#.getAttribute(#)".}
proc setAttr(e: Element, k, v: cstring) {.importjs: "#.setAttribute(#, #)".}
proc hasAttr(e: Element, k: cstring): bool {.importjs: "#.hasAttribute(#)".}
proc setVar(e: Element, k, v: cstring) {.importjs: "#.style.setProperty(#, #)".}
proc setHidden(e: Element, h: bool) {.importjs: "#.hidden = #".}
proc reflow(e: Element) {.importjs: "void #.offsetWidth".}
proc closestData(ev: Event, k: cstring): cstring {.importjs: "((e, k) => e.target.closest('[data-' + k + ']')?.getAttribute('data-' + k) ?? null)(#, #)".}
proc isTarget(ev: Event, e: Element): bool {.importjs: "(#.target === #)".}
proc kids(e: Element): seq[Element] {.importjs: "Array.from(#.children)".}
proc lastKids(e: Element, n: int): seq[Element] {.importjs: "Array.from(#.children).slice(-#)".}
proc innerW(e: Element): float {.importjs: "#.clientWidth".}
proc expose(splash: proc (first: bool), lesson: proc (), lineFor: proc (d: JsDate): cstring) {.importjs:
  "window.parlokuSplash = {splash: #, lesson: #, lineFor: #}".}

let q = $search()
let reduced = lessMotion()
proc it(): bool = $docLang() == "it"
proc T(en, it: string): string = (if it(): it else: en)
proc loc(): cstring = (if it(): "it-IT" else: "en-GB")

var root, card: Element
var timer: TimeOut
var run = 0

# ---------- the daily splash
const lines = [
  ("Six letters are waiting for you, and they're in no hurry.", "Sei lettere ti aspettano, e non hanno fretta."),
  ("The words are hiding well today. Seek better.", "Oggi le parole si nascondono bene. Tu cercale meglio."),
  ("A coffee, a grid, six letters.", "Un caffè, una griglia, sei lettere."),
  ("No letter repeats itself, not even on a {day}.", "Nessuna lettera si ripete, nemmeno di {day}."),
  ("Thirty-six cells, zero rush.", "Trentasei caselle, zero fretta."),
  ("The tiles are polished and ready.", "Le tessere sono lucidate e pronte."),
  ("Thought of the day: every word has a beginning.", "Pensiero del giorno: ogni parola ha un inizio."),
  ("Six rows, six columns, six boxes. And one smile.", "Sei righe, sei colonne, sei riquadri. E un sorriso."),
  ("The little sudoku that thinks in words.", "Il sudoku piccolo che pensa a parole."),
  ("First the first letter. The rest follows.", "Prima la prima lettera. Il resto viene da sé."),
  ("Breathe. Drag. Repeat.", "Respira. Trascina. Ripeti."),
  ("A grid a day keeps the boredom away.", "Una griglia al giorno toglie la noia di torno."),
  ("No numbers today: letters only, promise.", "Oggi niente numeri: solo lettere, promesso."),
  ("Every cell knows what it wants. Just ask it nicely.", "Ogni casella sa già cosa vuole. Basta chiederglielo con gentilezza."),
  ("A perfect {day} for six letters.", "Un {day} perfetto per sei lettere."),
  ("Small grid, big satisfaction.", "Piccola griglia, grande soddisfazione."),
  ("Mistakes are allowed: a double tap sends a letter back.", "Sbagliare si può: un doppio tocco e la lettera torna giù."),
  ("Words are clues in disguise.", "Le parole sono indizi travestiti."),
  ("Six colours, six letters, one solution.", "Sei colori, sei lettere, una sola soluzione."),
  ("Today's letters stretched and warmed up.", "Le lettere di oggi hanno fatto stretching."),
  ("Up, down, left, right. Never diagonal.", "Su, giù, destra, sinistra. Mai in diagonale."),
]

proc special(month, day: int): (string, string) =
  case &"{month:02}-{day:02}"
  of "01-01": ("Happy new year! New grid, same six letters.", "Buon anno! Griglia nuova, sei lettere di sempre.")
  of "10-31": ("Boo! Even the letters are in costume.", "Bu! Anche le lettere sono in maschera.")
  of "12-25": ("Merry Christmas! Six letters under the tree.", "Buon Natale! Sei lettere sotto l'albero.")
  else: ("", "")

proc today(): JsDate =
  ## ?day=2026-12-25 previews another day, at the current hour
  let i = q.find("day=")
  if i >= 0 and q.len >= i + 14:
    let s = q[i + 4 ..< i + 14]
    try: return newDate(parseInt(s[0..3]), parseInt(s[5..6]) - 1, parseInt(s[8..9]), newDate().hours)
    except ValueError: discard
  newDate()

proc hello(d: JsDate): string =
  let h = d.hours
  if h >= 5 and h < 12: T("Good morning!", "Buongiorno!")
  elif h >= 12 and h < 18: T("Good afternoon!", "Buon pomeriggio!")
  elif h >= 18 and h < 23: T("Good evening!", "Buonasera!")
  else: T("Hello, night owl!", "Ciao, nottambulo!")

proc lineOf(d: JsDate): string =
  ## the line of the day: the same for everyone, a special one on a few days of the year
  var pair = special(d.month, d.day)
  if pair[0] == "": pair = lines[d.dayNumber mod lines.len]
  T(pair[0], pair[1]).replace("{day}", $d.weekday(loc()))

proc logo(): string =
  for i, ch in "PARLOKU":
    result.add &"""<i style="background:var(--g{i mod 6});color:var(--i{i mod 6});animation-delay:{0.15 + i.float * 0.07:.2f}s">{ch}</i>"""

proc open() =
  root.setHidden(false)
  document.body.style.overflow = "hidden"
  nextFrame(proc (t: float) = root.classList.add("in"))

proc close() =
  clearTimeout(timer)
  inc run
  lsSet("parloku:seen", "1")
  root.classList.remove("in")
  document.body.style.overflow = ""
  discard setTimeout(proc () =
    root.setHidden(true)
    card.innerHTML = "", 350)

proc lesson()

proc splash(first: bool) =
  clearTimeout(timer)
  let d = today()
  const stay = 3200
  var html = &"""
    <div class="sp-top"><span class="sp-date">{$d.longDate(loc())}</span></div>
    <div class="sp-hello">{hello(d)}</div>
    <p class="sp-line">{lineOf(d)}</p>
    <div class="sp-logo">{logo()}</div>
    <p class="sp-what">{T("a mini sudoku with words", "un mini sudoku con parole")}</p>"""
  if first:
    html.add &"""<p class="sp-first">{T("First time here?", "È la prima volta qui?")}</p>
      <div class="sp-acts"><button class="sp-btn main" data-go="learn">{T("How do I play? 👀", "Come si gioca? 👀")}</button>
      <button class="sp-btn" data-go="play">{T("I know it, let's play", "Lo conosco, si gioca")}</button></div>"""
  else:
    html.add &"""<div class="sp-acts"><button class="sp-btn main" data-go="play">{T("Play ▸", "Gioca ▸")}</button>
      <button class="sp-btn link" data-go="learn">{T("how do I play?", "come si gioca?")}</button></div>
      <div class="sp-bar"><i style="animation-duration:{stay}ms"></i></div>"""
  card.innerHTML = cstring(html)
  card.onclick = proc (ev: Event) =
    let go = closestData(ev, "go")
    if go.isNil: return
    if go == "learn": lesson() else: close()
  if not first: timer = setTimeout(close, stay)

# ---------- the lesson
# It explains the rules on an example of its own, not on a puzzle of the game: no spoilers. AMARENA, MENTA, MARE use six
# letters; the grid below holds each of them as a single path from its start cell (made with a small search).
const exampleLetters = "AEMNRT"
# No word turns back on itself in a U, and the three givens leave one solution under the game's rules.
# Three flavours of a summer day, each in the colour of its outline: AMARENA red, MENTA green, MARE blue.
const exampleSolution = "RATMNE" & "MENART" & "AMRTEN" & "TNERAM" & "NRMETA" & "ETANMR"
const exampleWords = [("AMARENA", 29), ("MENTA", 26), ("MARE", 3)]
const exampleGivens = @[8, 17, 35]
# the gestures beat: a letter put by hand, then the bottom row gets one more and has a single free cell left
# (the row holds that letter, two of AMARENA and a given)
const putCell = 30
const rowFill = [31]
const lastFree = 34
var letters, solution: string
var givens: seq[int]
var clues: seq[Clue]

proc pathOf(word: string, start: int): seq[int] =
  ## the walk that spells `word` in the solution, from `start`
  var path: seq[int]
  proc go(c, i: int): bool =
    if solution[c] != word[i] or c in path: return false
    path.add c
    if i == word.len - 1: return true
    let (r, k) = (c div 6, c mod 6)
    for (ok, n) in [(r > 0, c - 6), (r < 5, c + 6), (k > 0, c - 1), (k < 5, c + 1)]:
      if ok and go(n, i + 1): return true
    path.setLen(path.len - 1)
    false
  discard go(start, 0)
  path

var stage, svg, texts, acts, dots: Element
var chips: seq[Element]
var cellT: array[36, Element]
var resizing: proc () = nil
window.addEventListener("resize", proc (ev: Event) =
  if not resizing.isNil: resizing())

proc li(ch: char): int = letters.find(ch)

proc wait(ms: int): Future[void] =
  let ms = if reduced: min(ms, 60) else: ms
  newPromise(proc (resolve: proc ()) = discard setTimeout(resolve, ms))

proc sleep(ms: int) {.async.} =
  ## a pause that stops the lesson if it was closed or restarted meanwhile
  let me = run
  await wait(ms)
  if me != run: raise newException(Stop, "stop")

proc frame(): Future[void] =
  ## two animation frames: the new element is on screen before it moves
  newPromise(proc (resolve: proc ()) = nextFrame(proc (t: float) = nextFrame(proc (t: float) = resolve())))

proc mk(cls: string, html = "", parent: Element = nil): Element =
  result = document.createElement("div")
  result.className = cstring(cls)
  if html != "": result.innerHTML = cstring(html)
  (if parent.isNil: stage else: parent).appendChild(result)

proc at(e: Element, x, y: float) =
  e.setVar("--x", cstring(&"{x:.3f}"))
  e.setVar("--y", cstring(&"{y:.3f}"))

proc colour(e: Element, ch: char) =
  let i = li(ch)
  e.classList.add("col")
  e.style.background = cstring(&"var(--g{i})")
  e.style.color = cstring(&"var(--i{i})")

proc cellXY(c: int): (float, float) = (float(c mod 6) + 0.07, float(c div 6) + 0.07)
proc trayXY(i: int): (float, float) = (float(i) + 0.07, 6.4)

proc home(t: Element) =
  ## a tile flies back to its letter below the grid and fades out
  let (x, y) = trayXY(li(($t.innerHTML)[0]))
  t.at(x, y)
  t.classList.add("ghost")

proc place(t: Element, c: int) =
  let (x, y) = cellXY(c)
  t.classList.remove("ghost")
  t.at(x, y)

proc tap(f: Element) {.async.} =
  ## two quick presses of the finger
  f.classList.remove("tap")
  f.reflow
  f.classList.add("tap")
  await sleep(650)

proc say(html: string, step: int) =
  texts.innerHTML = cstring(html.split('\n').mapIt(&"""<p class="in">{it}</p>""").join(""))
  for i, d in kids(dots):
    if i <= step: d.classList.add("on") else: d.classList.remove("on")

proc ask(buttons: seq[(string, string, bool)], column = false): Future[cstring] =
  ## buttons as (label, value, main?): the value clicked
  acts.className = if column: "tu-acts col" else: "tu-acts"
  newPromise(proc (resolve: proc (v: cstring)) =
    var html = ""
    for (t, v, m) in buttons:
      html.add &"""<button class="sp-btn{(if m: " main" else: "")}" data-v="{v}">{t}</button>"""
    acts.innerHTML = cstring(html)
    acts.onclick = proc (ev: Event) =
      let v = closestData(ev, "v")
      if not v.isNil:
        acts.innerHTML = ""
        resolve(v))

proc next() {.async.} =
  let me = run
  discard await ask(@[(T("next →", "avanti →"), "next", true)])
  if me != run: raise newException(Stop, "stop")

proc gridSvg(): string =
  ## the classic mini sudoku grid, as in the game: plain cells, thin lines, thick box lines
  result = """<g class="tu-grid">"""
  for c in 0 ..< 36:
    result.add &"""<rect class="thin" x="{c mod 6}" y="{c div 6}" width="1" height="1"/>"""
  result.add """<rect class="tu-hl" id="tu-hl" x="0" y="0" width="0" height="0"/>"""
  result.add """<path class="thick" d="M0 0H6V6H0Z M3 0V6 M0 2H6 M0 4H6"/></g><g id="tu-paths"></g>"""   # word outlines: under the tiles

proc highlight(x, y, w, h = 0.0) =
  let r = svg.querySelector("#tu-hl")
  if w == 0:
    r.classList.remove("on")
    return
  for (k, v) in [("x", x), ("y", y), ("width", w), ("height", h)]: r.setAttr(cstring(k), cstring($v))
  r.classList.add("on")

proc fly(cells: seq[int], gap: int) {.async.} =
  ## tiles of the solution fly from the tray into `cells`
  for c in cells:
    if not cellT[c].isNil: continue
    let ch = solution[c]
    let t = mk("tu-t", $ch)
    colour(t, ch)
    let (x0, y0) = trayXY(li(ch))
    t.at(x0, y0)
    cellT[c] = t
    await frame()
    let (x, y) = cellXY(c)
    t.at(x, y)
    await sleep(gap)

proc rowOf(r: int): seq[int] = toSeq(0 .. 5).mapIt(r * 6 + it)
proc colOf(k: int): seq[int] = toSeq(0 .. 5).mapIt(it * 6 + k)
proc boxOf(b: int): seq[int] = toSeq(0 .. 5).mapIt((b div 2 * 2 + it div 3) * 6 + (b mod 2) * 3 + it mod 3)
let allCells = toSeq(0 ..< 36)

proc showClues(cur = -1) =
  ## the three words above the grid, as in the game: each in the colour of its start mark and outline
  let box = card.querySelector("#tu-clues")
  var h = ""
  for i, c in clues:
    h.add &"""<span class="{(if i == cur: "cur" else: "")}" style="color:var(--w{i mod 3})">{c.word}</span>"""
  box.innerHTML = cstring(h)
  box.classList.add("on")

proc trace(i: int, lit: var seq[int]) {.async.} =
  ## a word lights up on the solved grid: its start mark, then its outline along its cells
  let c = clues[i]
  showClues(i)
  for p in c.path:
    if p notin lit: lit.add p
  for p in allCells:
    if p in lit: cellT[p].classList.remove("dim") else: cellT[p].classList.add("dim")
  let n = mk("tu-n")
  n.style.borderColor = cstring(&"var(--w{i mod 3})")
  n.at(c.c.float, c.r.float)
  await frame()
  n.classList.add("on")
  var d = ""
  for k, p in c.path: d.add &"""{(if k > 0: "L" else: "M")}{float(p mod 6) + 0.5} {float(p div 6) + 0.5} """
  let paths = stage.querySelector("#tu-paths")
  paths.insertAdjacentHTML("beforeend", cstring(&"""<path class="tu-path out" pathLength="1" d="{d}" style="stroke:var(--w{i mod 3})"/><path class="tu-path in" pathLength="1" d="{d}"/>"""))
  let els = paths.lastKids(2)
  await frame()
  for e in els: e.classList.add("on")
  for p in c.path:
    let t = cellT[p]
    t.classList.remove("bump")
    t.reflow
    t.classList.add("bump")
    await sleep(1600 div c.path.len)

proc play() {.async.} =
  let words = clues.mapIt(it.word)
  # 1 · three words
  say(T("Here are three words, just an example.", "Ecco tre parole, per esempio."), 0)
  for w, word in words:
    let step = min(1.0, 6 / word.len)    # a word longer than the grid is wide gets smaller tiles
    let x0 = (6 - word.len.float * step) / 2 + 0.07 - (1 - step) / 2
    for i, ch in word:
      let t = mk("tu-t ghost", $ch)
      t.setAttr("data-ch", cstring($ch))
      if step < 1: t.setVar("--s", cstring(&"{step * 0.97:.3f}"))
      t.at(x0 + i.float * step, 0.6 + w.float * 1.3 + 0.4)
      chips.add t
      await frame()
      t.classList.remove("ghost")
      t.at(x0 + i.float * step, 0.6 + w.float * 1.3)
      await sleep(70)
    await sleep(380)
  say(T(&"<b>{words.join(\", \")}</b>. Look closely at their letters…", &"<b>{words.join(\", \")}</b>. Guarda bene le loro lettere…"), 0)
  await next()

  # 2 · the same six letters
  for t in chips:
    colour(t, ($t.attr("data-ch"))[0])
    await sleep(45)
  let spaced = toSeq(letters.items).mapIt($it).join(" ")
  say(T(&"They are all made of the same <b>six letters</b>: {spaced}.", &"Sono fatte tutte delle stesse <b>sei lettere</b>: {spaced}."), 1)
  await sleep(900)
  var kept: seq[char]
  for chip in chips:
    let t = chip
    let ch = ($t.attr("data-ch"))[0]
    let (x, y) = trayXY(li(ch))
    t.setVar("--s", "1")
    t.at(x, y)
    if ch in kept:
      closureScope:                    # each fading tile keeps its own `t`
        let gone = t
        discard setTimeout(proc () = gone.classList.add("ghost"), 600)
    else: kept.add ch
    await sleep(55)
  await sleep(700)
  say(T("One copy of each goes down here: these are our <b>six symbols</b>.\nSix different symbols are just what a <b>mini sudoku</b> needs.",
        "Una copia di ognuna si mette giù: sono i nostri <b>sei simboli</b>.\nSei simboli diversi sono proprio quelli che servono a un <b>mini sudoku</b>."), 1)
  await next()

  # 3 · the mini sudoku, for everyone (no question: someone who knows it loses a few seconds, nobody gets lost)
  svg.querySelector(".tu-grid").classList.add("on")
  say(T("A mini sudoku is a 6×6 grid: 36 cells.\nThe game is to fill every cell with one of the six symbols.",
        "Un mini sudoku è una griglia 6×6: 36 caselle.\nIl gioco è riempire ogni casella con uno dei sei simboli."), 2)
  await sleep(600)
  await next()
  highlight(0, 0, 6, 1)
  say(T("<b>Rule 1.</b> Every row has each symbol exactly once.", "<b>Regola 1.</b> In ogni riga c’è ogni simbolo, una volta sola."), 3)
  await fly(rowOf(0), 170)
  await next()
  highlight(0, 0, 1, 6)
  say(T("<b>Rule 2.</b> Same for every column.", "<b>Regola 2.</b> Lo stesso in ogni colonna."), 3)
  await fly(colOf(0), 170)
  await next()
  highlight(0, 0, 3, 2)
  say(T("<b>Rule 3.</b> Same for every 2×3 box, the ones with a thick border. There are six of them.",
        "<b>Regola 3.</b> Lo stesso in ogni riquadro 2×3, quelli con il bordo spesso. Ce ne sono sei."), 3)
  await fly(boxOf(0), 220)
  await next()
  highlight()
  say(T("No repeats in any row, column or box: that’s a solved mini sudoku.",
        "Nessun doppione in righe, colonne e riquadri: ecco un mini sudoku risolto."), 3)
  await fly(allCells, 45)
  await sleep(500)
  await next()

  # 4 · the words are in the grid
  showClues()
  say(T("Here the symbols are letters, and the three words are <b>hidden in the grid</b>. They stay up there, each with its own colour.",
        "Qui i simboli sono lettere, e le tre parole sono <b>nascoste nella griglia</b>. Restano lassù, ognuna con il suo colore."), 4)
  await sleep(300)
  var lit: seq[int]
  await trace(0, lit)
  say(T(&"<b>{words[0]}</b> starts in the cell with its colour and goes one step at a time: up, down, left or right. Never diagonally.",
        &"<b>{words[0]}</b> parte dalla casella del suo colore e va avanti un passo alla volta: su, giù, a destra o a sinistra. Mai in diagonale."), 4)
  await next()
  say(T(&"Same for <b>{words[1]}</b> and <b>{words[2]}</b>, each from its own cell, each in its own colour.",
        &"Lo stesso per <b>{words[1]}</b> e <b>{words[2]}</b>, ognuna dalla sua casella, ognuna con il suo colore."), 4)
  for i in 1 ..< clues.len: await trace(i, lit)
  await next()

  # 5 · how a puzzle starts
  showClues()
  stage.querySelector("#tu-paths").innerHTML = ""
  for p in allCells:
    cellT[p].classList.remove("dim")
    if p notin givens: cellT[p].home
  await sleep(700)
  say(T("A puzzle starts almost empty: a few letters, and the coloured cell where each word starts. The words are your clues.",
        "Un puzzle parte quasi vuoto: qualche lettera e la casella colorata dove parte ogni parola. Le parole sono i tuoi indizi."), 5)
  await next()

  # 6 · the gestures, shown by a finger
  let finger = mk("tu-f", "<i></i>")
  proc point(x, y: float) = finger.at(x, y)
  proc pointCell(c: int) = point(float(c mod 6), float(c div 6))
  proc pointTray(ch: char) = point(float(li(ch)), 6.33)
  pointTray(solution[putCell])
  await frame()
  finger.classList.add("on")
  say(T("<b>Put a letter:</b> drag one of the six letters below onto an empty cell.",
        "<b>Mettere una lettera:</b> trascina una delle sei lettere in basso su una casella vuota."), 6)
  await sleep(700)
  cellT[putCell].classList.remove("ghost")
  pointCell(putCell)
  let (xp, yp) = cellXY(putCell)
  cellT[putCell].at(xp, yp)
  await sleep(800)
  await next()
  let w0 = clues[0]
  say(T(&"<b>Where a word starts:</b> double tap the coloured cell, and the first letter of {w0.word} goes in by itself.",
        &"<b>Dove parte una parola:</b> doppio tocco sulla casella colorata, e la prima lettera di {w0.word} si mette da sola."), 6)
  pointCell(w0.path[0])
  await sleep(700)
  await finger.tap
  cellT[w0.path[0]].place(w0.path[0])
  await sleep(700)
  await next()
  say(T(&"<b>Stretch a word:</b> drag its last letter onto the next cell, and the next letter comes by itself. Go back and it goes away.",
        &"<b>Allungare una parola:</b> trascina la sua ultima lettera sulla casella accanto, e arriva la lettera dopo. Tornando indietro la togli."), 6)
  await sleep(500)
  let paths = stage.querySelector("#tu-paths")
  proc outline(n: int) =
    var d = ""
    for q, p in w0.path[0 ..< n]: d.add &"""{(if q > 0: "L" else: "M")}{float(p mod 6) + 0.5} {float(p div 6) + 0.5} """
    paths.innerHTML = if n < 2: "" else: cstring(&"""<path class="tu-path out on" d="{d}" style="stroke:var(--w0);stroke-dasharray:none"/><path class="tu-path in on" d="{d}" style="stroke-dasharray:none"/>""")
  for k in 1 ..< w0.path.len:
    pointCell(w0.path[k])
    await sleep(350)
    cellT[w0.path[k]].place(w0.path[k])
    outline(k + 1)
    await sleep(450)
  await next()
  for c in rowFill:
    cellT[c].place(c)
    await sleep(250)
  say(T("<b>The last free cell</b> of a row, column or box: double tap it and the missing letter comes. On other cells a double tap does nothing.",
        "<b>L'ultima casella libera</b> di una riga, colonna o riquadro: doppio tocco e arriva la lettera che manca. Sulle altre caselle il doppio tocco non fa niente."), 6)
  highlight(0, 5, 6, 1)
  pointCell(lastFree)
  await sleep(900)
  await finger.tap
  cellT[lastFree].place(lastFree)
  await sleep(700)
  highlight()
  await next()
  say(T("<b>Take back:</b> double tap a letter and it goes back down. Inside a word, the letters after it go back too.",
        "<b>Togliere:</b> doppio tocco su una lettera e torna giù. Dentro una parola, tornano giù anche le lettere dopo."), 6)
  pointCell(w0.path[1])
  await sleep(700)
  await finger.tap
  for c in w0.path[1 .. ^1]: cellT[c].home
  outline(1)
  await sleep(700)
  finger.classList.remove("on")
  await next()

  # 7 · over to you, with the options
  card.querySelector("#tu-clues").classList.remove("on")
  resizing = nil                       # the board is done: it folds away, so the three choices fit on any phone
  stage.classList.add("gone")
  say(T("Your turn! Play the first puzzle on your own, let the tutorial guide you (it shows the solution), or try the gestures in istruzioni.",
        "Tocca a te! Gioca il primo puzzle senza aiuto, fatti guidare dal tutorial (ti mostra la soluzione) o prova i gesti nelle istruzioni."), 6)
  let me = run
  let how = await ask(@[(T("▸ Play on my own", "▸ Gioco e basta"), "play", true),
                        (T("🎓 Guide me (spoilers)", "🎓 Guidami (spoiler!)"), "guide", false),
                        (T("📖 Istruzioni", "📖 Istruzioni"), "howto", false)], column = true)
  if me != run: return
  lsSet("parloku:learned", "1")
  close()
  if how == "guide":
    let b = document.getElementById("tutorial")
    if not b.isNil: b.click()
  elif how == "howto":
    let a = document.getElementById("howto")
    if not a.isNil: a.click()

proc lesson() =
  clearTimeout(timer)
  inc run
  let me = run
  lsSet("parloku:seen", "1")
  card.onclick = nil
  card.innerHTML = cstring(&"""<div class="tu-head"><div class="tu-dots">{"<i></i>".repeat(7)}</div>
    <button class="sp-x" id="tu-skip">{T("skip ✕", "salta ✕")}</button></div>
    <div class="tu-clues" id="tu-clues"></div>
    <div class="tu-stage" id="tu-stage"><svg viewBox="0 0 6 7.35">{gridSvg()}</svg></div>
    <div class="tu-text" id="tu-text"></div><div class="tu-acts" id="tu-acts"></div>""")
  stage = document.getElementById("tu-stage")
  svg = stage.querySelector("svg")
  texts = document.getElementById("tu-text")
  acts = document.getElementById("tu-acts")
  dots = card.querySelector(".tu-dots")
  document.getElementById("tu-skip").onclick = proc (ev: Event) = close()
  proc size() =
    let c = stage.innerW / 6
    stage.setVar("--c", cstring(&"{c:.2f}px"))
    stage.style.height = cstring(&"{7.35 * c:.0f}px")
  size()
  resizing = size
  chips = @[]
  for c in 0 ..< 36: cellT[c] = nil
  discard (proc () {.async.} =
    try: await play()
    except: discard                    # stopped: the lesson was closed or started again
    if me == run: resizing = nil)()

# ---------- start
proc start() =
  root = document.getElementById("splash")
  if root.isNil: return
  card = document.getElementById("splash-card")
  letters = exampleLetters
  solution = exampleSolution
  givens = exampleGivens
  for (w, start) in exampleWords:
    clues.add Clue(word: w, r: start div 6, c: start mod 6, path: pathOf(w, start))
  root.addEventListener("click", proc (ev: Event) =
    if ev.isTarget(root) and card.querySelector("#tu-stage").isNil: close())
  expose(proc (first: bool) = (open(); splash(first)), proc () = (open(); lesson()), proc (d: JsDate): cstring = cstring(lineOf(d)))
  if root.hasAttr("data-manual") or "nosplash" in q or "tutorial" in q: return
  open()
  if "learn" in q: lesson()
  else: splash("splash=first" in q or lsGet("parloku:seen").isNil)

document.addEventListener("DOMContentLoaded", proc (ev: Event) = start())
