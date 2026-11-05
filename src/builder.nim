## The Parloku builder: pick three words, lay each one on the grid as a snake, add letter clues,
## and watch the solver (puzzlepaw's `parloku/solver`, compiled to JS) update the pencil marks
## and count the solutions of the resulting puzzle. Writes builder.html at the repo root.
import std/[json, os, strformat, strutils]
import nimib
import style, builder_style
import parloku/[types, solver]

nbInit
nb.doc.filename = currentSourcePath().parentDir.parentDir / "builder.html"
nb.doc.context["title"] = %"Parloku builder"
nb.doc.context["stylesheet"] = %(pageStyle & builderCss)
nb.doc.context["highlight"] = %""
nb.doc.context["disableHighlightJs"] = %true
func pageHeader(blk: JsonNode, nb: Nb): string = ""
nb.backend.partials["header"] = pageHeader

nbRawHtml: """
<div class="bld" id="bld">
<h1><span class="tile">P</span>arloku <span class="sub">builder</span></h1>
<div class="sets" id="sets"></div>
<div class="row custom"><input id="custom" spellcheck="false" autocomplete="off" placeholder="tre parole, es. NERO ROSA ORO" aria-label="tre parole"><button class="btn" id="use">usa</button></div>
<div class="say" id="say"></div>
<div class="words" id="words"></div>
<div class="stage"><svg class="board" id="board" viewBox="-6 -6 480 480"></svg></div>
<div class="tray" id="tray"></div>
<div class="panel" id="panel"></div>
<details class="how"><summary>come funziona</summary>
<p><b>Parole.</b> Tocca una parola, poi trascina il dito sulla griglia: la prima casella che tocchi è l'inizio, e ogni casella vicina (su, giù, destra, sinistra) aggiunge la lettera successiva. Torna indietro sulla casella precedente per togliere l'ultima lettera, o usa ⌫. ✕ cancella tutta la parola. Toccando una casella lontana la parola riparte da lì.</p>
<p><b>Indizi.</b> Trascina una delle sei lettere sotto la griglia su una casella: diventa un indizio fisso. Tocca un indizio (senza parole selezionate) per toglierlo.</p>
<p><b>Annotazioni.</b> Ogni casella vuota mostra le lettere che può ancora avere in almeno una griglia completa, date le lettere messe finora. Una casella senza possibilità diventa rossa.</p>
<p><b>Il puzzle.</b> Il giocatore vede solo le caselle di partenza delle parole e gli indizi. Il riquadro sotto conta le soluzioni di quel puzzle: quando è 1, è pronto. Le parole possono ripassare su una casella e condividere caselle, come da regolamento.</p>
</details>
</div>
"""

nbText: """
The builder is a [nimib](https://github.com/pietroppeter/nimib) notebook. The solver is
[puzzlepaw](https://github.com/pietroppeter/puzzlepaw)'s `parloku/solver`, the same Nim module that
runs in the terminal tools, compiled to JavaScript with the page. The word sets below are checked
natively while the page is built:
"""

nbCode:
  const wordSets = [
    "ITALIA PASTA ALPI", "AMICA GIOCO MAGIA", "IMPARA PRIMA MATITA", "PAROLE PERLE OPERA",
    "LOGICA GIOCA CALCOLI", "ALBA LUNA NUBE", "CENA PANE PERA", "ESTATE MARE SERATA",
    "CANE PESCE APE", "NERO ROSA ORO", "CANTO NOTE TONO", "PROVA TROVA PORTA"]
  proc lettersOf(words: seq[string]): string =
    for w in words:
      for ch in w:
        if ch notin result: result.add ch
  for s in wordSets:
    let ws = s.split(' ')
    var p: Problem
    let ls = lettersOf(ws)
    for i in 0 ..< min(6, ls.len): p.letters[i] = ls[i]
    for w in ws: p.wordHints.add HintWord(pos: (row: 0, col: 0), word: w)
    let issues = validate(p)
    echo &"{s:<20} letters {ls.len}  ", (if ls.len == 6 and issues.len == 0: "ok" else: $issues)

nbJsFromCode:
  import std/[dom, strutils, strformat, sequtils, math, algorithm]
  import parloku/[types, code, solver]

  # ---------------- browser glue ----------------
  proc dataOf(ev: Event, k: cstring): cstring {.importjs: "((e, k) => e.target.closest('[data-' + k + ']')?.getAttribute('data-' + k) ?? null)(#, #)".}
  proc clientXY(ev: Event): (float, float) {.importjs: "((e) => ({Field0: e.clientX, Field1: e.clientY}))(#)".}
  proc rectOf(e: Element): (float, float, float, float) {.importjs: "((r) => ({Field0: r.left, Field1: r.top, Field2: r.width, Field3: r.height}))(#.getBoundingClientRect())".}
  proc capture(e: Element, ev: Event) {.importjs: "#.setPointerCapture(#.pointerId)".}
  proc prevent(ev: Event) {.importjs: "#.preventDefault()".}
  proc value(e: Element): cstring {.importjs: "#.value".}
  proc setValue(e: Element, v: cstring) {.importjs: "#.value = #".}
  proc setPos(e: Element, x, y: float) {.importjs: "((e, x, y) => { e.style.transform = 'translate(' + x + 'px,' + y + 'px)' })(#, #, #)".}
  proc copyText(s: cstring) {.importjs: "(s => { try { navigator.clipboard.writeText(s) } catch (e) {} })(#)".}
  proc setSkin(v: cstring) {.importjs: "document.documentElement.dataset.skin = document.body.dataset.skin = #".}
  proc setHidden(e: Element, v: bool) {.importjs: "#.hidden = #".}
  setSkin("niki")

  const playUrl = "https://pietroppeter.github.io/parloku/?p="
  const sets = [
    "ITALIA PASTA ALPI", "AMICA GIOCO MAGIA", "IMPARA PRIMA MATITA", "PAROLE PERLE OPERA",
    "LOGICA GIOCA CALCOLI", "ALBA LUNA NUBE", "CENA PANE PERA", "ESTATE MARE SERATA",
    "CANE PESCE APE", "NERO ROSA ORO", "CANTO NOTE TONO", "PROVA TROVA PORTA"]
  const C = 78.0

  # ---------------- state ----------------
  type Snake = object
    word: string
    path: seq[Coord]

  var letters: array[6, char]
  var snakes: seq[Snake]
  var givens: seq[HintLetter]
  var sel = -1                 # selected word
  var dragging = false
  var message = ""

  proc li(ch: char): int =
    for i, l in letters:
      if l == ch: return i
    -1

  proc cellAt(r, c: int): int = r * 6 + c
  proc adjacent(a, b: Coord): bool = abs(a.row - b.row) + abs(a.col - b.col) == 1

  proc fixedGrid(skipWord = -1): (array[36, char], array[36, bool]) =
    ## letters laid down so far (words and clues), and cells asked for two different letters
    var g: array[36, char]
    var clash: array[36, bool]
    for i in 0 ..< 36: g[i] = '.'
    proc put(p: Coord, ch: char) =
      let k = cellAt(p.row, p.col)
      if g[k] == '.': g[k] = ch
      elif g[k] != ch: clash[k] = true
    for gv in givens: put(gv.pos, gv.letter)
    for wi, s in snakes:
      if wi == skipWord: continue
      for i, p in s.path: put(p, s.word[i])
    (g, clash)

  proc canPut(wi: int, p: Coord, i: int): bool =
    ## letter i of word wi may go on p if the cell is empty or already holds that letter
    let ch = snakes[wi].word[i]
    let (g, _) = fixedGrid(wi)
    let k = cellAt(p.row, p.col)
    if g[k] != '.' and g[k] != ch: return false
    for j, q in snakes[wi].path:
      if q == p and snakes[wi].word[j] != ch: return false
    true

  # ---------------- analysis ----------------
  type Analysis = object
    fixed: array[36, char]
    bad: array[36, bool]          # cell with no possible letter, or a letter repeated in a unit
    marks: array[36, seq[char]]
    exact: bool                   # marks come from the solver (else from plain sudoku elimination)
    complete: bool                # at least one full grid fits what is on the board
    count: int                    # solutions of the puzzle the player would get
    countComplete: bool
    placed: int                   # words with a start cell

  proc analyze(): Analysis =
    let (g, clash) = fixedGrid()
    result.fixed = g
    var anyClash = false
    for k in 0 ..< 36:
      if clash[k]:
        result.bad[k] = true
        anyClash = true
    # plain sudoku: a letter already in a row, column or box is crossed out of its peers
    for k in 0 ..< 36:
      let (r, c) = (k div 6, k mod 6)
      var seen: set[char]
      for k2 in 0 ..< 36:
        if k2 == k or g[k2] == '.': continue
        let (r2, c2) = (k2 div 6, k2 mod 6)
        if r2 == r or c2 == c or (r2 div 2 == r div 2 and c2 div 3 == c div 3):
          if g[k] != '.' and g[k2] == g[k]:
            result.bad[k] = true
            anyClash = true
          seen.incl g[k2]
      if g[k] == '.':
        for l in letters:
          if l notin seen: result.marks[k].add l
        if result.marks[k].len == 0: result.bad[k] = true
    # exact pencil marks: every letter some complete grid can put there
    var p: Problem
    p.letters = letters
    for k in 0 ..< 36:
      if g[k] != '.': p.letterHints.add HintLetter(pos: (row: k div 6, col: k mod 6), letter: g[k])
    for s in snakes:
      if s.path.len > 0: p.wordHints.add HintWord(pos: s.path[0], word: s.word)
    var o = defaultOptions(limit = 1, keep = 0)
    if not anyClash and solve(p, o).count > 0:
      result.complete = true
      result.exact = true
      let cands = candidates(p)
      for k in 0 ..< 36:
        if g[k] == '.': result.marks[k] = cands[k div 6][k mod 6]
    # the puzzle as the player sees it: word starts and clues only
    var pz: Problem
    pz.letters = letters
    pz.letterHints = givens
    for s in snakes:
      if s.path.len > 0:
        pz.wordHints.add HintWord(pos: s.path[0], word: s.word)
        inc result.placed
    let r = solve(pz, defaultOptions(limit = 1000, keep = 0))
    result.count = r.count
    result.countComplete = r.complete

  proc puzzleCode(): string =
    var pz: Problem
    pz.letters = letters
    pz.letterHints = givens
    for s in snakes:
      if s.path.len > 0: pz.wordHints.add HintWord(pos: s.path[0], word: s.word)
    encodeProblem(pz)

  # ---------------- drawing ----------------
  proc blobPath(s: float, seed: int, amp: float): string =
    ## the game's soft blob: 8 points with varied radii joined by Catmull-Rom curves
    var pts: seq[(float, float)]
    for k in 0 ..< 8:
      let a = k.float * PI / 4 + 0.3 * sin(seed.float)
      let side = if k mod 2 == 0: 1.0 else: -0.6
      let rr = s * (1 + amp * sin(seed.float * 1.7 + k.float * 2.3) * side)
      pts.add (rr * cos(a), rr * sin(a))
    result = &"M{pts[0][0]:.1f} {pts[0][1]:.1f}"
    for k in 0 ..< 8:
      let (p0, p1, p2, p3) = (pts[(k + 7) mod 8], pts[k], pts[(k + 1) mod 8], pts[(k + 2) mod 8])
      let c1 = (p1[0] + (p2[0] - p0[0]) / 6, p1[1] + (p2[1] - p0[1]) / 6)
      let c2 = (p2[0] - (p3[0] - p1[0]) / 6, p2[1] - (p3[1] - p1[1]) / 6)
      result.add &"C{c1[0]:.1f} {c1[1]:.1f} {c2[0]:.1f} {c2[1]:.1f} {p2[0]:.1f} {p2[1]:.1f}"
    result.add "Z"

  proc tileSvg(ch: char, scale = 1.0): string =
    let i = li(ch)
    &"""<g transform="scale({scale})"><path class="tb g{i}" d="{blobPath(30, i * 7 + 3, 0.09)}"/>""" &
      &"""<text y="12" text-anchor="middle" font-size="34" class="glyph i{i}">{ch}</text></g>"""

  proc center(p: Coord): (float, float) = (p.col.float * C + C / 2, p.row.float * C + C / 2)

  var an: Analysis

  proc renderBoard() =
    var s = ""
    # where the selected word could go next
    var next: set[0..35]
    if sel >= 0:
      let w = snakes[sel]
      if w.path.len > 0 and w.path.len < w.word.len:
        let last = w.path[^1]
        for (dr, dc) in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
          let p = (row: last.row + dr, col: last.col + dc)
          if p.row in 0..5 and p.col in 0..5:
            let k = cellAt(p.row, p.col)
            let ch = w.word[w.path.len]
            if canPut(sel, p, w.path.len) and (an.fixed[k] == ch or ch in an.marks[k]): next.incl k
    for k in 0 ..< 36:
      let (r, c) = (k div 6, k mod 6)
      var cls = if (r div 2 + c div 3) mod 2 == 0: "cell ca" else: "cell cb"
      if k in next: cls.add " tint"
      if an.bad[k]: cls.add " bad"
      s.add &"""<rect class="{cls}" x="{c.float * C}" y="{r.float * C}" width="{C}" height="{C}"/>"""
    s.add """<g class="boxlines">"""
    for x in [3]: s.add &"""<line x1="{x.float * C}" y1="0" x2="{x.float * C}" y2="{6 * C}"/>"""
    for y in [2, 4]: s.add &"""<line x1="0" y1="{y.float * C}" x2="{6 * C}" y2="{y.float * C}"/>"""
    s.add "</g>"
    # snakes: a soft band under the letters, then the start rings
    for wi, w in snakes:
      if w.path.len >= 2:
        var pts = ""
        for p in w.path:
          let (x, y) = center(p)
          pts.add &"{x:.0f},{y:.0f} "
        let on = if wi == sel: " on" else: ""
        s.add &"""<polyline class="snake w{wi mod 3}{on}" points="{pts}"/>"""
    # pencil marks and letters
    for k in 0 ..< 36:
      let p = (row: k div 6, col: k mod 6)
      let (x, y) = center(p)
      let ch = an.fixed[k]
      if ch != '.':
        var isGiven = false
        for gv in givens:
          if gv.pos == p: isGiven = true
        let gcls = if isGiven: "fixed given" else: "fixed"
        s.add &"""<g class="{gcls}" transform="translate({x:.0f},{y:.0f})">{tileSvg(ch, 0.92)}"""
        if isGiven: s.add """<circle class="pin" cx="22" cy="-22" r="6"/>"""
        s.add "</g>"
      else:
        let m = an.marks[k]
        if m.len == 0:
          s.add &"""<text class="none" x="{x:.0f}" y="{y + 12:.0f}" text-anchor="middle">∅</text>"""
        elif m.len == 1 and an.exact:
          s.add &"""<text class="forced glyph" x="{x:.0f}" y="{y + 11:.0f}" text-anchor="middle">{m[0]}</text>"""
        else:
          for i, l in letters:
            if l in m:
              let mx = x - 22 + float(i mod 3) * 22
              let my = y - 9 + float(i div 3) * 26
              s.add &"""<text class="mark" x="{mx:.0f}" y="{my:.0f}" text-anchor="middle">{l}</text>"""
    for wi, w in snakes:
      if w.path.len > 0:
        let (x, y) = center(w.path[0])
        s.add &"""<circle class="start w{wi mod 3}" cx="{x:.0f}" cy="{y:.0f}" r="35"/>"""
    document.getElementById("board").innerHTML = cstring(s)

  proc renderWords() =
    var s = ""
    for wi, w in snakes:
      let on = if wi == sel: " on" else: ""
      let done = if w.path.len == w.word.len: " done" else: ""
      s.add &"""<div class="wchip w{wi mod 3}{on}{done}" data-word="{wi}">"""
      for i, ch in w.word:
        let cls = if i < w.path.len: "l in" else: "l"
        s.add &"""<span class="{cls}">{ch}</span>"""
      if wi == sel:
        s.add &"""<button class="mini" data-back="{wi}" aria-label="togli l'ultima lettera">⌫</button>"""
        s.add &"""<button class="mini" data-clear="{wi}" aria-label="cancella la parola">✕</button>"""
      s.add "</div>"
    document.getElementById("words").innerHTML = cstring(s)

  proc renderTray() =
    var s = ""
    for l in letters:
      s.add &"""<svg class="ttile" data-letter="{l}" viewBox="-36 -36 72 72">{tileSvg(l)}</svg>"""
    document.getElementById("tray").innerHTML = cstring(s)

  proc renderPanel() =
    var s = ""
    let code = puzzleCode()
    if an.placed == 0:
      s.add """<div class="verdict"><b>·</b> metti la prima parola</div>"""
    else:
      let n = if an.countComplete: $an.count else: "≥ " & $an.count
      let cls = if an.count == 1: "one" elif an.count == 0: "zero" else: "many"
      let what = if an.count == 1: "soluzione: il puzzle è pronto" elif an.count == 0: "soluzioni" else: "soluzioni"
      s.add &"""<div class="verdict {cls}"><b>{n}</b> {what}</div>"""
      s.add &"""<p class="note">Partendo solo dalle caselle iniziali delle {an.placed} parole e da {givens.len} indizi.</p>"""
      s.add &"""<div class="code"><code>{code}</code></div>"""
      s.add &"""<div class="acts"><a class="btn" href="{playUrl}{code}" target="_blank" rel="noopener">▶ gioca</a>"""
      s.add """<button class="btn" id="copy">🔗 copia link</button><button class="btn" id="reset">↺ svuota</button></div>"""
    if not an.complete:
      s.add """<p class="warn">Nessuna griglia completa è compatibile con le lettere messe: c'è una casella senza possibilità o un conflitto.</p>"""
    document.getElementById("panel").innerHTML = cstring(s)

  proc renderSets() =
    var s = ""
    for i, st in sets:
      s.add &"""<button class="btn" data-set="{i}">{st.replace(" ", " · ")}</button>"""
    document.getElementById("sets").innerHTML = cstring(s)

  proc say(m: string) =
    message = m
    document.getElementById("say").innerHTML = cstring(m)

  proc refresh(full = true) =
    if full: an = analyze()
    renderBoard()
    renderWords()
    if full: renderPanel()

  # ---------------- word sets ----------------
  proc loadSet(text: string) =
    let ws = text.toUpperAscii.splitWhitespace
    var ls = ""
    for w in ws:
      for ch in w:
        if ch notin {'A'..'Z'}:
          say &"«{w}»: solo lettere A-Z"
          return
        if ch notin ls: ls.add ch
    if ws.len == 0: return
    if ls.len != 6:
      say &"Queste parole usano {ls.len} lettere diverse: ne servono esattamente 6."
      return
    for w in ws:
      for i in 1 ..< w.len:
        if w[i] == w[i - 1]:
          say &"«{w}» ha una doppia: due lettere uguali non possono stare in caselle vicine."
          return
    var sorted = ls
    sorted.sort()
    for i in 0 ..< 6: letters[i] = sorted[i]
    snakes = @[]
    for w in ws: snakes.add Snake(word: w)
    givens = @[]
    sel = 0
    renderTray()
    say "Tocca una parola e trascinala sulla griglia, lettera per lettera."
    refresh()

  # ---------------- snake gestures ----------------
  let board = document.getElementById("board")

  proc cellFrom(ev: Event): (bool, Coord) =
    let (x, y) = clientXY(ev)
    let (l, t, w, h) = rectOf(board)
    # the viewBox has a 6 unit margin around the 468 unit board
    let bx = (x - l) / w * 480 - 6
    let by = (y - t) / h * 480 - 6
    let c = int(floor(bx / C))
    let r = int(floor(by / C))
    if r in 0..5 and c in 0..5: (true, (row: r, col: c)) else: (false, (row: -1, col: -1))

  proc extend(p: Coord): bool =
    ## dragging onto p: grow the selected word, or shrink it when going back
    let n = snakes[sel].path.len
    if n > 0 and p == snakes[sel].path[^1]: return false
    if n >= 2 and p == snakes[sel].path[^2]:
      snakes[sel].path.setLen(n - 1)
      return true
    if n > 0 and n < snakes[sel].word.len and adjacent(snakes[sel].path[^1], p) and canPut(sel, p, n):
      snakes[sel].path.add p
      return true
    false

  board.addEventListener("pointerdown", proc (ev: Event) =
    let (ok, p) = cellFrom(ev)
    if not ok: return
    if sel < 0:
      for i, gv in givens:
        if gv.pos == p:
          givens.delete(i)
          refresh()
          return
      say "Scegli prima una parola qui sopra."
      return
    let n = snakes[sel].path.len
    if n > 0 and p == snakes[sel].path[^1]:
      discard
    elif n > 0 and n < snakes[sel].word.len and adjacent(snakes[sel].path[^1], p):
      discard extend(p)
    else:
      # a fresh start for this word from p
      snakes[sel].path = @[]
      if canPut(sel, p, 0):
        snakes[sel].path.add p
      else:
        say &"La casella ha già un'altra lettera: {snakes[sel].word} non può partire da lì."
        refresh()
        return
    dragging = true
    board.capture(ev)
    prevent(ev)
    refresh(full = false))

  board.addEventListener("pointermove", proc (ev: Event) =
    if not dragging or sel < 0: return
    let (ok, p) = cellFrom(ev)
    if ok and extend(p): refresh(full = false))

  proc endDrag(ev: Event) =
    if not dragging: return
    dragging = false
    let w = snakes[sel]
    if w.path.len == w.word.len:
      # done: pick the next word still to place
      var nxt = -1
      for i in 1 .. snakes.len:
        let j = (sel + i) mod snakes.len
        if snakes[j].path.len < snakes[j].word.len:
          nxt = j
          break
      sel = nxt
      if nxt < 0: say "Tutte le parole sono sulla griglia. Aggiungi indizi trascinando le lettere qui sotto."
      else: say &"Ora {snakes[nxt].word}."
    refresh()

  board.addEventListener("pointerup", endDrag)
  board.addEventListener("pointercancel", endDrag)

  document.getElementById("words").addEventListener("click", proc (ev: Event) =
    let b = dataOf(ev, "back")
    let c = dataOf(ev, "clear")
    if b != nil:
      let i = parseInt($b)
      if snakes[i].path.len > 0: snakes[i].path.setLen(snakes[i].path.len - 1)
      refresh()
      return
    if c != nil:
      snakes[parseInt($c)].path = @[]
      refresh()
      return
    let wv = dataOf(ev, "word")
    if wv != nil:
      let i = parseInt($wv)
      sel = if sel == i: -1 else: i
      if sel >= 0: say &"Trascina {snakes[sel].word} sulla griglia."
      else: say "Nessuna parola scelta: tocca un indizio per toglierlo."
      refresh(full = false))

  # ---------------- letter clues: drag a tile from the tray ----------------
  let ghost = document.createElement("div")
  ghost.className = "ghost"
  ghost.setHidden(true)
  document.body.appendChild(ghost)
  var carrying = '\0'

  let tray = document.getElementById("tray")
  tray.addEventListener("pointerdown", proc (ev: Event) =
    let l = dataOf(ev, "letter")
    if l == nil: return
    carrying = ($l)[0]
    ghost.innerHTML = cstring(&"""<svg viewBox="-36 -36 72 72">{tileSvg(carrying)}</svg>""")
    ghost.setHidden(false)
    let (x, y) = clientXY(ev)
    ghost.setPos(x - 32, y - 32)
    tray.capture(ev)
    prevent(ev))
  tray.addEventListener("pointermove", proc (ev: Event) =
    if carrying == '\0': return
    let (x, y) = clientXY(ev)
    ghost.setPos(x - 32, y - 32))
  proc drop(ev: Event) =
    if carrying == '\0': return
    ghost.setHidden(true)
    let (ok, p) = cellFrom(ev)
    let ch = carrying
    carrying = '\0'
    if not ok: return
    let (g, _) = fixedGrid()
    let k = cellAt(p.row, p.col)
    var mine = -1
    for i, gv in givens:
      if gv.pos == p: mine = i
    if g[k] != '.' and mine < 0:
      say "Quella casella ha già una lettera di una parola."
      return
    if mine >= 0: givens.delete(mine)
    givens.add HintLetter(pos: p, letter: ch)
    say &"Indizio {ch} in riga {p.row + 1}, colonna {p.col + 1}."
    refresh()
  tray.addEventListener("pointerup", drop)
  tray.addEventListener("pointercancel", proc (ev: Event) =
    carrying = '\0'
    ghost.setHidden(true))

  # ---------------- panel and set buttons ----------------
  document.getElementById("panel").addEventListener("click", proc (ev: Event) =
    let target = ev.target
    if target.isNil: return
    let id = $target.id
    if id == "copy":
      copyText(cstring(playUrl & puzzleCode()))
      target.innerHTML = "✓ copiato"
    elif id == "reset":
      for s in snakes.mitems: s.path = @[]
      givens = @[]
      sel = 0
      refresh())
  document.getElementById("sets").addEventListener("click", proc (ev: Event) =
    let i = dataOf(ev, "set")
    if i != nil:
      let t = sets[parseInt($i)]
      document.getElementById("custom").setValue(cstring(t))
      loadSet(t))
  document.getElementById("use").addEventListener("click", proc (ev: Event) =
    loadSet($document.getElementById("custom").value))

  renderSets()
  document.getElementById("custom").setValue(cstring(sets[0]))
  loadSet(sets[0])

nbSave
