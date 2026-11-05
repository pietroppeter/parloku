import std/[json, os, algorithm, sequtils]
import nimib
import style

nbInit
# write the page at the repo root (served by GitHub Pages), wherever the build is run from
nb.doc.filename = currentSourcePath().parentDir.parentDir / "index.html"
nb.doc.context["title"] = %"Parloku"
nb.doc.context["stylesheet"] = %pageStyle
nb.doc.context["highlight"] = %""
nb.doc.context["disableHighlightJs"] = %true
func pageHeader(blk: JsonNode, nb: Nb): string =
  ""                                   # the title says it all: no header line above the game
nb.backend.partials["header"] = pageHeader

var skinButtons = ""
for (id, label, flag) in skinList:
  skinButtons.add "<button data-skin=\"" & id & "\"><span class=\"dots\"><i></i><i></i><i></i></span>" & label & " " & flag & "</button>"
nbRawHtml: """
<div class="play" id="play">
<h1><span class="tile">P</span>arloku</h1>
<p class="lede" data-it="Un mini sudoku fatto di lettere, con delle parole nascoste.">A mini sudoku spelled in letters, with words hidden in it.</p>
<div class="game">
  <div class="picker"><button class="btn tut" id="tutorial" data-it="🎓 tutorial">🎓 tutorial</button><span id="picker"></span>
<div class="langs" id="langs"><button class="btn" data-lang="en">EN</button><button class="btn" data-lang="it">IT</button></div>
  </div>
  <div class="coach" id="coach" hidden>
    <div class="hd" id="coach-hd"></div>
    <p id="coach-text"></p>
    <div class="acts" id="coach-acts"></div>
  </div>
  <div class="clues" id="clues"></div>
  <div class="stage" id="board"></div>
  <div class="status">
    <span class="acts">
      <button class="btn" id="undo" data-it="↶<span class='tx'> annulla</span>" aria-label="undo" disabled>↶<span class="tx"> undo</span></button>
      <button class="btn" id="hint" data-it="💡<span class='tx'> aiuto</span>" aria-label="hint">💡<span class="tx"> hint</span></button>
      <button class="btn" id="reset" data-it="↺<span class='tx'> ricomincia</span>" aria-label="reset">↺<span class="tx"> reset</span></button>
      <button class="btn" id="share" data-it="🔗<span class='tx'> link</span>" aria-label="link">🔗<span class="tx"> link</span></button>
      <button class="btn" id="more" data-it="📖<span class='tx'> altro</span>" aria-label="more" hidden>📖<span class="tx"> more</span></button>
    </span>
  </div>
</div>
<div class="rules">
  <div data-it="<b>01 · SUDOKU</b>Ognuna delle sei lettere compare una volta in ogni riga, in ogni colonna e in ogni riquadro 2×3."><b>01 · SUDOKU</b>Each of the six letters appears once in every row, every column and every 2×3 box.</div>
  <div data-it="<b>02 · PAROLE</b>Ogni parola parte dalla casella con il suo cerchio colorato e si scrive un passo alla volta: in su, in giù, a destra o a sinistra. Il contorno cresce con le lettere."><b>02 · WORDS</b>Each word starts in the cell ringed in its colour and is spelled one step at a time, up, down, left or right. Its outline grows with the letters.</div>
  <div data-it="<b>03 · TESSERE</b>Sotto la griglia c'è una tessera per lettera. Tirala e si divide: la copia va su una casella. Riporta una tessera alla sua lettera e si riuniscono."><b>03 · TILES</b>Below the board is one tile per letter. Pull it and it divides: the copy goes on a cell. Bring a tile back to its letter and they merge.</div>
</div>
<div class="skins" id="skins">""" & skinButtons & """</div>
</div>
"""

nbText: """
Parloku is [Pietro](https://github.com/pietroppeter)'s word-flavoured
[mini sudoku](https://github.com/pietroppeter/puzzlepaw#parloku): a 6×6 grid, six letters instead of six digits,
and a few words threaded through the grid as extra clues. The puzzles come from
[puzzlepaw](https://github.com/pietroppeter/puzzlepaw), where they are crafted in a terminal UI.

This page is a [nimib](https://github.com/pietroppeter/nimib) notebook. Everything below is the Nim source
of the game you just played. Most blocks run **twice**: natively while nimib builds the page (that is where the
printed outputs come from) and in your browser, compiled with `nim js`. The dragging uses a tiny port of
**Declarative Dragging** ([Horowitz, Blinn & Heer, UIST 2026](https://declarative-dragging.github.io/)):
nobody wrote a drop handler, the code only lists the boards a drag can reach.
"""

nbRawHtml: """<h2><span class="num">01 · THE MODEL</span>Six letters, thirty-six tiles</h2>"""

nbText: """
A puzzle is six letters, a few given letters and the word clues. A *board* says which tile sits in each cell.
There are 36 tiles, six copies of each letter, so tile `id` is copy `id mod 6` of letter `id div 6`.
A given letter is just a tile that is glued down.

Puzzles travel as a short code that fits in a URL, so a future builder (or a daily puzzle) only has to hand out a link.
The code is `LETTERS_GIVENS_WORDS` (the format puzzlepaw uses too): givens are row, column, letter and words are
row, column, word, both 0-based and separated by dots.
"""

nbCodeAnd(nbJsFromCode):
  import std/[math, strformat, strutils, sequtils]

  type
    Coord = tuple[row, col: int]
    Given = object
      pos: Coord
      letter: char
    Clue = object
      pos: Coord
      word: string
    Puzzle = object
      letters: string        # the six letters
      givens: seq[Given]
      clues: seq[Clue]
    Grid = array[36, char]   # '.' for an empty cell
    Board = object
      cells: array[36, int]  # tile id in each cell, -1 when empty
      moves: int

  func idx(r, c: int): int = r * 6 + c
  func idx(p: Coord): int = idx(p.row, p.col)

  proc encode(p: Puzzle): string =
    ## LETTERS_GIVENS_WORDS, the code format shared with puzzlepaw
    p.letters & "_" & p.givens.mapIt(&"{it.pos.row}{it.pos.col}{it.letter}").join(".") &
      "_" & p.clues.mapIt(&"{it.pos.row}{it.pos.col}{it.word}").join(".")

  proc decode(code: string): Puzzle =
    var c = code.strip(chars = {'?', '#', ' '})
    if c.startsWith("p="): c = c[2 .. ^1]
    let parts = c.toUpperAscii.split('_')
    if parts.len != 3: return
    result.letters = parts[0]
    for kind in 1 .. 2:
      for item in parts[kind].split('.'):
        if item.len >= 3 and item[0] in '0'..'5' and item[1] in '0'..'5':
          let pos = (row: ord(item[0]) - ord('0'), col: ord(item[1]) - ord('0'))
          if kind == 1: result.givens.add Given(pos: pos, letter: item[2])
          else: result.clues.add Clue(pos: pos, word: item[2 .. ^1])

  proc valid(p: Puzzle): bool =
    p.letters.len == 6 and p.letters.deduplicate.len == 6 and
      p.givens.allIt(it.letter in p.letters and it.pos.row in 0..5 and it.pos.col in 0..5) and
      p.clues.allIt(it.word.allIt(it in p.letters) and it.pos.row in 0..5 and it.pos.col in 0..5)

  var puz: Puzzle                # the puzzle being played

  proc letterOf(id: int): char = puz.letters[id div 6]
  proc isGiven(cell: int): bool = puz.givens.anyIt(idx(it.pos) == cell)

  proc grid(b: Board): Grid =
    for c, id in b.cells:
      result[c] = '.'
      if id >= 0: result[c] = letterOf(id)

  proc boardOf(p: Puzzle, g: Grid): Board =
    ## a board holding the letters of `g`, using the lowest free copy of each letter
    var used: array[6, int]
    for c in 0 ..< 36:
      result.cells[c] = -1
      let li = p.letters.find(g[c])
      if li >= 0 and used[li] < 6:
        result.cells[c] = li * 6 + used[li]
        inc used[li]

  proc startGrid(p: Puzzle): Grid =
    for c in result.mitems: c = '.'
    for gv in p.givens: result[idx(gv.pos)] = gv.letter

nbText: "The puzzles are the JSON files crafted with puzzlepaw, read at build time and turned into codes:"

nbCode:
  var builtin: seq[(string, string)]   # (title, code)
  var answerKeys: seq[Grid]            # the solutions stored in the JSON files
  var files = toSeq(walkFiles(currentSourcePath().parentDir.parentDir / "data" / "puzzle*.json"))
  files.sort()
  for f in files:
    let all = parseFile(f)
    let j = all["problem"]
    var p = Puzzle(letters: j["letters"].mapIt(it.getStr).join)
    for h in j["letterHints"]:
      p.givens.add Given(pos: (h["pos"][0].getInt, h["pos"][1].getInt), letter: h["letter"].getStr[0])
    for h in j["wordHints"]:
      p.clues.add Clue(pos: (h["pos"][0].getInt, h["pos"][1].getInt), word: h["word"].getStr)
    builtin.add (p.clues.mapIt(it.word).join(" · "), p.encode)
    var key: Grid
    for r, row in all["solution"].getElems:
      for c, ch in row.getElems: key[idx(r, c)] = ch.getStr[0]
    answerKeys.add key
  for (title, code) in builtin:
    echo title, "\n  ?p=", code, "  valid: ", decode(code).valid

nbRawHtml: """<h2><span class="num">02 · THE RULES, AS CODE</span>Checking, tracing, solving</h2>"""

nbText: """
Three functions carry the rules. `clashes` finds repeated letters in a row, column or box (they glow red on the board).
`trace` walks a clue through the grid with a depth-first search and returns the longest prefix it can spell, so
the clue chips light up letter by letter and the path is drawn over the tiles.
With `wild = true` an empty cell matches any letter, which is what a solver needs to prune early.
"""

nbCodeAnd(nbJsFromCode):
  proc makeUnits(): seq[seq[int]] =
    for r in 0 .. 5: result.add toSeq(0 .. 5).mapIt(idx(r, it))
    for c in 0 .. 5: result.add toSeq(0 .. 5).mapIt(idx(it, c))
    for b in 0 .. 5:
      var u: seq[int]
      for r in 0 .. 1:
        for c in 0 .. 2: u.add idx((b div 2) * 2 + r, (b mod 2) * 3 + c)
      result.add u
  let units = makeUnits()

  proc peers(cell: int): seq[int] =
    for u in units:
      if cell in u:
        for j in u:
          if j != cell and j notin result: result.add j
  let peersOf = toSeq(0 ..< 36).mapIt(peers(it))

  proc clashes(g: Grid): seq[int] =
    for c in 0 ..< 36:
      if g[c] != '.' and peersOf[c].anyIt(g[it] == g[c]): result.add c

  proc trace(g: Grid, clue: Clue, wild = false): seq[int] =
    ## longest prefix of the word that can be walked from its start cell
    ## (the rules let a path come back to a cell it already used)
    var best, path: seq[int]
    let word = clue.word
    proc walk(cell, i: int) =
      if best.len == word.len: return
      let ok = g[cell] == word[i] or (wild and g[cell] == '.')
      if not ok: return
      path.add cell
      if path.len > best.len: best = path
      if i + 1 < word.len:
        let (r, c) = (cell div 6, cell mod 6)
        if r > 0: walk(cell - 6, i + 1)
        if r < 5: walk(cell + 6, i + 1)
        if c > 0: walk(cell - 1, i + 1)
        if c < 5: walk(cell + 1, i + 1)
      discard path.pop
    walk(idx(clue.pos), 0)
    best

  proc solved(p: Puzzle, g: Grid): bool =
    '.' notin g and g.clashes.len == 0 and p.clues.allIt(g.trace(it).len == it.word.len)

  proc solve(p: Puzzle, limit = 2): seq[Grid] =
    ## backtracking with "fewest candidates first", pruning on the clues;
    ## stops after `limit` solutions (2 is enough to tell unique from ambiguous)
    var g = startGrid(p)
    var sols: seq[Grid]
    proc fits(g: Grid, cell: int, ch: char): bool = peersOf[cell].allIt(g[it] != ch)
    proc cluesOk(g: Grid): bool = p.clues.allIt(g.trace(it, wild = true).len == it.word.len)
    proc go(g: var Grid) =
      if sols.len >= limit: return
      var best = -1
      var bestN = 99
      for c in 0 ..< 36:
        if g[c] == '.':
          let n = p.letters.countIt(fits(g, c, it))
          if n < bestN: (best, bestN) = (c, n)
      if best < 0:
        if solved(p, g): sols.add g
        return
      for ch in p.letters:
        if fits(g, best, ch):
          g[best] = ch
          if cluesOk(g): go(g)
          g[best] = '.'
    if g.clashes.len == 0 and cluesOk(g): go(g)
    sols

nbText: "At build time the solver checks each puzzle has exactly one solution, and traces the clues through it:"

nbCode:
  for i, (title, code) in builtin:
    let p = decode(code)
    let sols = p.solve
    let verdict = if sols.len == 1: " (unique)" else: "s found, stopped"
    let key = if sols[0] == answerKeys[i]: "matches" else: "DIFFERS FROM"
    echo title, ": ", sols.len, " solution", verdict, ", ", key, " the answer key in data/"
    for clue in p.clues:
      let path = sols[0].trace(clue).mapIt(&"r{it div 6 + 1}c{it mod 6 + 1}")
      echo &"  {clue.word:<7}", path.join(" → ")

nbText: """
The solver is also the seed of a puzzle *builder*: pick letters, givens and words, and it tells you whether the
setup has zero, one or many solutions. In the game it powers the 💡 button, which glides one correct tile into place.
"""

nbRawHtml: """<h2><span class="num">03 · A LOGICAL PATH</span>Solving like a person</h2>"""

nbText: """
Backtracking finds the answer but can't explain it. The 🎓 tutorial needs moves a person can see, so here is
Pietro's method as code. First put the first letter of every word in its ringed cell. Then follow each word
letter by letter: the next letter sits next to the previous one, has to fit the sudoku, and has to leave a way
to finish the word (`spellings` lists every walk that still could). When only one cell qualifies, the letter is forced.
When no word moves, plain sudoku singles take over: a cell with one candidate left, or a letter with one place left in a row,
column or box. The tutorial asks for the next step after every drop, so it copes with any order and even with mistakes.
"""

nbCodeAnd(nbJsFromCode):
  type
    StepKind = enum skStart, skWord, skNaked, skHidden, skFix, skReveal
    Step = object
      kind: StepKind
      cell: int              # where the tile goes (-1: no step)
      letter: char
      clue: int              # start and word steps: which clue
      unit: int              # hidden singles: which row, column or box
      path: seq[int]         # word steps: the word so far, ending in `cell`
      dead: seq[int]         # word steps: neighbours that fit the sudoku but can't finish the word

  var lang = "en"            # "en" or "it", set by the page
  proc L(en, it: string): string = (if lang == "it": it else: en)

  proc cands(p: Puzzle, g: Grid, c: int): string =
    if g[c] != '.': return $g[c]
    for ch in p.letters:
      if peersOf[c].allIt(g[it] != ch): result.add ch

  proc neighbours(at: int): seq[int] =
    for nb in [at - 6, at + 6, at - 1, at + 1]:
      if nb >= 0 and nb < 36 and (abs(nb - at) == 6 or nb div 6 == at div 6): result.add nb

  proc spellings(p: Puzzle, g: Grid, clue: Clue): seq[seq[int]] =
    ## every walk that could still spell the clue: each cell holds its letter or could take it,
    ## and the walk never puts the same letter twice in a row, column or box
    var found: seq[seq[int]]
    var cur: seq[int]
    let word = clue.word
    proc walk(cell, i: int) =
      let ch = word[i]
      if not (g[cell] == ch or (g[cell] == '.' and ch in cands(p, g, cell))): return
      for k, prev in cur:
        if prev == cell and word[k] != ch: return
        if prev != cell and word[k] == ch and prev in peersOf[cell]: return
      cur.add cell
      if cur.len == word.len: found.add cur
      else:
        for nb in neighbours(cell): walk(nb, i + 1)
      discard cur.pop
    walk(idx(clue.pos), 0)
    found

  proc wordStep(p: Puzzle, g: Grid): Step =
    result.cell = -1
    for i, clue in p.clues:
      let start = idx(clue.pos)
      if g[start] == '.': return Step(kind: skStart, cell: start, letter: clue.word[0], clue: i, path: @[start])
    for i, clue in p.clues:
      let sp = spellings(p, g, clue)
      var path = @[idx(clue.pos)]
      for k in 1 ..< clue.word.len:
        let ch = clue.word[k]
        let at = path[^1]
        let fits = neighbours(at).filterIt(g[it] == ch or (g[it] == '.' and ch in cands(p, g, it)))
        let next = sp.mapIt(it[k]).deduplicate
        if next.len != 1: break
        path.add next[0]
        if g[next[0]] == '.':
          return Step(kind: skWord, cell: next[0], letter: ch, clue: i, path: path,
                      dead: fits.filterIt(it != next[0]))

  proc singleStep(p: Puzzle, g: Grid): Step =
    result.cell = -1
    for c in 0 ..< 36:
      if g[c] == '.':
        let cs = cands(p, g, c)
        if cs.len == 1: return Step(kind: skNaked, cell: c, letter: cs[0])
    for u, cells in units:
      for ch in p.letters:
        if cells.anyIt(g[it] == ch): continue
        let spots = cells.filterIt(g[it] == '.' and ch in cands(p, g, it))
        if spots.len == 1: return Step(kind: skHidden, cell: spots[0], letter: ch, unit: u)

  proc logicalStep(p: Puzzle, g: Grid, solution: Grid): Step =
    ## the next move a person would make; a wrong tile is pointed out first
    for c in 0 ..< 36:
      if g[c] != '.' and solution[c] != '.' and g[c] != solution[c]:
        return Step(kind: skFix, cell: c, letter: g[c])
    result = wordStep(p, g)
    if result.cell < 0: result = singleStep(p, g)
    if result.cell < 0:
      for c in 0 ..< 36:
        if g[c] == '.' and solution[c] != '.': return Step(kind: skReveal, cell: c, letter: solution[c])

  proc rc(c: int): string = &"r{c div 6 + 1}c{c mod 6 + 1}"
  proc nth(k: int): string =
    const en = ["first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth"]
    const it = ["prima", "seconda", "terza", "quarta", "quinta", "sesta", "settima", "ottava"]
    if k < 1 or k > 8: return $k
    L(en[k - 1], it[k - 1])

  proc inUnit(u: int): string =
    ## "in row 5" / "nella riga 5"
    if u < 6: L(&"in row {u + 1}", &"nella riga {u + 1}")
    elif u < 12: L(&"in column {u - 5}", &"nella colonna {u - 5}")
    else: L(&"in box {u - 11}", &"nel riquadro {u - 11}")

  proc blockUnit(g: Grid, cell: int, ch: char): int =
    ## why `ch` can't go in `cell`: -1 the cell is taken, else the unit that already has `ch`
    if g[cell] != '.': return -1
    for u, cells in units:
      if cell in cells and cells.anyIt(g[it] == ch): return u
    -2

  proc an(ch: char): string = (if ch in "AEFHILMNORSX": "an" else: "a")

  proc blocked(g: Grid, cells: seq[int], ch: char): seq[string] =
    ## "r3c1 and r5c1 are in column 1, which already has an A"
    var keys: seq[int]
    for c in cells:
      let k = blockUnit(g, c, ch)
      if k notin keys: keys.add k
    for k in keys:
      let group = cells.filterIt(blockUnit(g, it, ch) == k)
      let names = group.mapIt(rc(it)).join(L(" and ", " e "))
      let isEn = if group.len > 1: "are" else: "is"
      let isIt = if group.len > 1: "sono" else: "è"
      let takenIt = if group.len > 1: "occupate" else: "occupata"
      if k == -1:
        result.add L(&"{names} {isEn} taken", &"{names} {isIt} {takenIt}")
      elif k >= 0:
        result.add L(&"{names} {isEn} {inUnit(k)}, which already has {an(ch)} {ch}",
                     &"{names} {isIt} {inUnit(k)}, che ha già una {ch}")

  proc explain(p: Puzzle, g: Grid, s: Step): string =
    let w = if s.clue < p.clues.len: p.clues[s.clue].word else: ""
    case s.kind
    of skStart:
      L(&"<b>{w}</b> starts in cell {s.clue + 1}, so {rc(s.cell)} is <b>{s.letter}</b>.",
        &"<b>{w}</b> parte dalla casella {s.clue + 1}, quindi {rc(s.cell)} è <b>{s.letter}</b>.")
    of skWord:
      let k = s.path.len
      let prev = s.path[^2]
      var notes: seq[string]
      var others: seq[int]
      for o in neighbours(prev):
        if o == s.cell or o in s.path: continue
        if o notin s.dead:
          others.add o
          continue
        var g2 = g
        g2[o] = s.letter
        let nxt = w[k]
        let room = neighbours(o).filterIt(g2[it] == nxt or (g2[it] == '.' and nxt in cands(p, g2, it)))
        if room.len == 0:
          notes.add L(&"{rc(o)} fits {s.letter}, but then the next letter, {nxt}, would have no room",
                      &"in {rc(o)} la {s.letter} ci starebbe, ma poi la lettera dopo, {nxt}, non avrebbe posto")
        else:
          notes.add L(&"{rc(o)} fits {s.letter}, but from there {w} can't be finished",
                      &"in {rc(o)} la {s.letter} ci starebbe, ma da lì {w} non si può completare")
      notes = blocked(g, others, s.letter) & notes
      L(&"The {nth(k)} letter of <b>{w}</b>, <b>{s.letter}</b>, sits next to {rc(prev)}. ",
        &"La {nth(k)} lettera di <b>{w}</b>, <b>{s.letter}</b>, sta accanto a {rc(prev)}. ") &
        notes.join("; ") & L(&". So {rc(s.cell)} is <b>{s.letter}</b>.", &". Quindi {rc(s.cell)} è <b>{s.letter}</b>.")
    of skNaked:
      let seen = p.letters.filterIt(it != s.letter).join(" ")
      L(&"{rc(s.cell)} already sees {seen} in its row, column and box: only <b>{s.letter}</b> fits.",
        &"{rc(s.cell)} vede già {seen} nella sua riga, colonna e riquadro: ci sta solo la <b>{s.letter}</b>.")
    of skHidden:
      L(&"{inUnit(s.unit).capitalizeAscii}, <b>{s.letter}</b> fits only in {rc(s.cell)}.",
        &"{inUnit(s.unit).capitalizeAscii}, la <b>{s.letter}</b> può andare solo in {rc(s.cell)}.")
    of skFix:
      L(&"The {s.letter} in {rc(s.cell)} is not right. Drag it back to its letter below the board.",
        &"La {s.letter} in {rc(s.cell)} non è giusta. Riportala alla sua lettera sotto la griglia.")
    of skReveal:
      L(&"This one is tricky: {rc(s.cell)} is <b>{s.letter}</b>.", &"Questa è difficile: {rc(s.cell)} è <b>{s.letter}</b>.")

nbText: "The path it finds for the first puzzle, which the tutorial walks through:"

nbCode:
  block:
    let p = decode(builtin[0][1])
    let sol = p.solve[0]
    var g = startGrid(p)
    var n = 0
    while '.' in g:
      let s = logicalStep(p, g, sol)
      inc n
      echo &"{n:>2}. ", explain(p, g, s).replace("<b>", "").replace("</b>", "")
      g[s.cell] = s.letter

nbRawHtml: """<h2><span class="num">04 · THE DRAG SPEC</span>Listing futures instead of handling drops</h2>"""

nbText: """
The drag engine is the one from [Declarative Dragging, in Nim](https://pietroppeter.github.io/claude-artifacts/declarative-dragging-nim/):
a view is a pure function from model to keyed, positioned items, and a *behaviour* turns a list of reachable
models into a picker that chooses the one landing the held item closest to the pointer.
Tick the box and drag a tile on the board above: the dashed squares are every board this drag can reach.
"""
nbRawHtml: """<p class="machinery-slot" id="machinery-slot"></p>"""

nbRawHtml: "<details><summary>show the engine (closest · within · orElse, ~60 lines)</summary>"
nbCodeAnd(nbJsFromCode):
  type
    Vec = object
      x, y: float
    Item = object            ## one keyed element of a rendered view
      key: string            ## identity across states (what your eye tracks)
      pos: Vec               ## where it sits in this state
      svg: string            ## what it looks like, drawn around (0, 0)
    Render[S] = proc (s: S): seq[Item]
    Choice[S] = object
      ok: bool
      state: S
      land: Vec              ## where the dragged element lands in `state`
      dist: float
    Picker[S] = object       ## a behaviour, instantiated at drag start
      lands: seq[Vec]        ## speculative landing spots
      pick: proc (p: Vec): Choice[S]
    Behavior[S] = proc (render: Render[S], key: string): Picker[S]

  func vec(x, y: float): Vec = Vec(x: x, y: y)
  func `+`(a, b: Vec): Vec = vec(a.x + b.x, a.y + b.y)
  func `-`(a, b: Vec): Vec = vec(a.x - b.x, a.y - b.y)
  func norm(a: Vec): float = hypot(a.x, a.y)

  proc locate[S](render: Render[S], s: S, key: string): Vec =
    ## speculative rendering: draw `s` without painting it, report where `key` lands
    for it in render(s):
      if it.key == key: return it.pos
    vec(NaN, NaN)

  proc closest[S](states: seq[S]): Behavior[S] =
    result = proc (render: Render[S], key: string): Picker[S] =
      var lands: seq[Vec]
      for s in states: lands.add render.locate(s, key)
      result.lands = lands
      result.pick = proc (p: Vec): Choice[S] =
        result.dist = Inf
        for i, s in states:
          let d = norm(lands[i] - p)
          if d < result.dist:
            result = Choice[S](ok: true, state: s, land: lands[i], dist: d)

  proc within[S](b: Behavior[S], radius: float): Behavior[S] =
    result = proc (render: Render[S], key: string): Picker[S] =
      let inner = b(render, key)
      result.lands = inner.lands
      result.pick = proc (p: Vec): Choice[S] =
        result = inner.pick(p)
        if result.dist > radius: result.ok = false

  proc orElse[S](a, b: Behavior[S]): Behavior[S] =
    result = proc (render: Render[S], key: string): Picker[S] =
      let pa = a(render, key)
      let pb = b(render, key)
      result.lands = pa.lands & pb.lands
      result.pick = proc (p: Vec): Choice[S] =
        result = pa.pick(p)
        if not result.ok: result = pb.pick(p)
nbRawHtml: "</details>"

nbText: """
The view puts each tile either in its cell or on its letter's spot below the board. All the tiles still to place sit
exactly on top of each other, so the player sees one tile per letter: pulling the top one off looks like the tile
dividing, and bringing one back looks like two tiles merging.
Six colours, one per letter. The view only names classes (`g0`…`g5`, `ca`, `boxline`, `wp c1`…), so the page's CSS *skin* picks the palette, the fonts and even the tile shape: square, rounded or round.
"""

nbCodeAnd(nbJsFromCode):
  ## colours live in the page's CSS skins: --g0..--g5 tile colours, --i0..--i5 their letters, --c0..--c4 the clues
  const cell = 78.0
  const bx = 66.0
  const by = 16.0

  proc cellPos(c: int): Vec = vec(bx + float(c mod 6) * cell + cell / 2, by + float(c div 6) * cell + cell / 2)
  proc stackPos(li: int): Vec = vec(50 + li.float * 100, 566)

  proc blobPath(s: float, seed: int, amp: float): string =
    ## a soft closed blob around the origin: 8 points with varied radii, joined by Catmull-Rom curves
    var pts: seq[Vec]
    for k in 0 ..< 8:
      let a = k.float * PI / 4 + 0.3 * sin(seed.float)
      var side = -0.6
      if k mod 2 == 0: side = 1.0
      let rr = s * (1 + amp * sin(seed.float * 1.7 + k.float * 2.3) * side)
      pts.add vec(rr * cos(a), rr * sin(a))
    result = &"M{pts[0].x:.1f} {pts[0].y:.1f}"
    for k in 0 ..< 8:
      let (p0, p1, p2, p3) = (pts[(k + 7) mod 8], pts[k], pts[(k + 1) mod 8], pts[(k + 2) mod 8])
      let c1 = vec(p1.x + (p2.x - p0.x) / 6, p1.y + (p2.y - p0.y) / 6)
      let c2 = vec(p2.x - (p3.x - p1.x) / 6, p2.y - (p3.y - p1.y) / 6)
      result.add &"C{c1.x:.1f} {c1.y:.1f} {c2.x:.1f} {c2.y:.1f} {p2.x:.1f} {p2.y:.1f}"
    result.add "Z"

  proc shapes(li: int, cls = "tile"): string =
    ## every shape a skin may pick: square, rounded, round, and a blob of its own for each letter
    &"""<g class="{cls} s{li mod 2} g{li}"><rect class="sq" x="-31" y="-31" width="62" height="62" rx="3"/>""" &
      """<rect class="rd" x="-31" y="-31" width="62" height="62" rx="12"/><circle class="ci" r="32"/>""" &
      &"""<path class="bl" d="{blobPath(31.5, li * 7 + 3, 0.09)}"/>""" &
      """<circle class="ring" r="21"/></g>"""

  proc tileSvg(li: int, given: bool): string =
    let letter = puz.letters[li]
    ## all three shapes are drawn; the page's skin (CSS) shows one, and sets the colours
    result = shapes(li) & """<rect class="sh" x="-25" y="-26" width="50" height="20" rx="8"/>""" &
      &"""<text y="13" text-anchor="middle" font-size="36" class="glyph i{li}">{letter}</text>"""
    if given:
      result.add """<rect class="gv" x="-26" y="-26" width="52" height="52" rx="8"/><circle class="gvc" r="25"/>"""

  proc renderBoard(b: Board): seq[Item] =
    var at: array[36, int]
    for id in 0 ..< 36: at[id] = -1
    for c, id in b.cells:
      if id >= 0: at[id] = c
    for id in 0 ..< 36:
      let c = at[id]
      let pos = if c >= 0: cellPos(c) else: stackPos(id div 6)
      result.add Item(key: &"t{id}", pos: pos, svg: tileSvg(id div 6, c >= 0 and isGiven(c)))

nbText: """
And here is the entire interaction. Grabbing tile `id` lists one future per free cell (the tile in that cell;
if it came from another cell, the tiles swap; otherwise the old occupant goes home), snaps to the nearest within
half a cell, or else falls back to "the tile went back to its letter". Givens have no spec, so they can't be picked up.
"""

nbCodeAnd(nbJsFromCode):
  proc place(b: Board, id, cell: int): Board =
    result = b
    let src = b.cells.find(id)
    let other = b.cells[cell]
    if src == cell: return
    inc result.moves
    if src >= 0: result.cells[src] = -1
    result.cells[cell] = id
    if other >= 0 and src >= 0: result.cells[src] = other   # swap

  proc home(b: Board, id: int): Board =
    result = b
    let src = b.cells.find(id)
    if src >= 0:
      result.cells[src] = -1
      inc result.moves

  proc tileSpec(b: Board, key: string): Behavior[Board] =
    let id = parseInt(key[1 .. ^1])
    let src = b.cells.find(id)
    if src >= 0 and isGiven(src): return nil
    var futures: seq[Board]
    for c in 0 ..< 36:
      if not isGiven(c): futures.add b.place(id, c)
    closest(futures).within(cell * 0.6).orElse(closest(@[b.home(id)]))

nbText: "Driving it by hand at build time: grab the first letter's tile and hover between two cells of the top row."

nbCode:
  puz = decode(builtin[0][1])
  let b0 = puz.boardOf(puz.startGrid)
  let free = toSeq(0 ..< 36).filterIt(b0.cells.find(it) < 0)
  let key = &"t{free[0]}"
  let picker = tileSpec(b0, key)(renderBoard, key)
  let choice = picker.pick(vec(cellPos(2).x + 30, cellPos(2).y + 4))
  echo &"grabbed {key} ({letterOf(free[0])}): {picker.lands.len} futures rendered speculatively"
  echo &"pointer near r1c3 → shows the board with {letterOf(free[0])} at r1c{choice.state.cells.find(free[0]) + 1}, {int(choice.dist)}px away"
  let off = picker.pick(vec(300, 640))
  echo &"pointer below the board → {off.state.cells.find(free[0])} (-1: back with its letter)"

nbText: """
Around the tiles, the backdrop draws the board and red cells for clashes; the overlay draws each word's outline
on top: a ring on its start cell that grows around the letters as they are spelled. Both are plain functions of the board too, so nimib can also draw a
finished board at build time:
"""

nbCodeAnd(nbJsFromCode):
  var focusClue = -1             # the clue chip under the mouse, drawn bolder
  var maskTag = "wm"             # ids of the word-outline masks (the build-time spoiler uses its own)
  var coachTint: seq[int]        # tutorial: cells to tint (the reason for a step)
  var coachTarget = -1           # tutorial: the cell to fill (or empty)
  var coachStacks: seq[int]      # tutorial: letter stacks to make glow

  proc backdrop(b: Board): string =
    let g = b.grid
    let bad = g.clashes
    result = &"""<rect class="frame" x="{bx - 9}" y="{by - 9}" width="{cell * 6 + 18}" height="{cell * 6 + 18}" rx="14"/>"""
    for c in 0 ..< 36:
      let p = cellPos(c)
      let (r, col) = (c div 6, c mod 6)
      let base = if (r div 2 + col div 3) mod 2 == 0: "ca" else: "cb"
      let tinted = if c in coachTint: "tint" else: base
      let fill = if c in bad: "bad" else: tinted
      result.add &"""<rect class="cell {fill}" x="{p.x - cell/2 + 1.5}" y="{p.y - cell/2 + 1.5}" width="{cell - 3}" height="{cell - 3}" rx="7"/>"""
      if c in bad:
        result.add &"""<rect x="{p.x - cell/2 + 1.5}" y="{p.y - cell/2 + 1.5}" width="{cell - 3}" height="{cell - 3}" rx="7" class="badline"/>"""
    for i in 1 .. 2:
      let y = by + i.float * cell * 2
      result.add &"""<rect class="boxline" x="{bx}" y="{y - 2.5}" width="{cell * 6}" height="5"/>"""
    result.add &"""<rect class="boxline" x="{bx + cell * 3 - 2.5}" y="{by}" width="5" height="{cell * 6}"/>"""
    for i in 0 .. 5:                 # row and column numbers, for the tutorial's r3c4
      result.add &"""<text x="{bx - 22}" y="{cellPos(i * 6).y + 5}" text-anchor="middle" font-size="14" class="mono lbl">r{i + 1}</text>"""
      result.add &"""<text x="{cellPos(i).x}" y="{by + cell * 6 + 28}" text-anchor="middle" font-size="14" class="mono lbl">c{i + 1}</text>"""
    for li in coachStacks:
      let s = stackPos(li)
      result.add &"""<rect class="glow pulse" x="{s.x - 40}" y="{s.y - 40}" width="80" height="94" rx="18"/>"""
    # a letter with no tiles left shows an empty ring and a tick
    var left: array[6, int]
    for id in 0 ..< 36:
      if b.cells.find(id) < 0: inc left[id div 6]
    for li in 0 .. 5:
      let s = stackPos(li)
      if left[li] == 0:
        result.add &"""<rect class="empty" x="{s.x - 31}" y="{s.y - 31}" width="62" height="62" rx="12"/>"""
        result.add &"""<text class="done" x="{s.x}" y="{s.y + 9}" text-anchor="middle" font-size="26">✓</text>"""

  proc overlay(b: Board): string =
    let g = b.grid
    let n = puz.clues.len
    for i, clue in puz.clues:
      # each word is an outline in its own dark colour: a ring on its start cell that grows around its letters
      let path = g.trace(clue)
      let ink = &"w{i mod 3}"
      let t = if focusClue == i: 8.0 else: 5.0
      let rr = cell * 0.47
      if path.len <= 1:
        let p = cellPos(idx(clue.pos))
        result.add &"""<circle class="wo {ink}" cx="{p.x}" cy="{p.y}" r="{rr + t / 2:.1f}" stroke-width="{t}"/>"""
      else:
        var d = ""
        for k, c in path:
          let p = cellPos(c)
          let cmd = if k == 0: "M" else: "L"
          d.add &"{cmd}{p.x:.1f},{p.y:.1f} "
        # round stroke joins round the outer corners; the inner (concave) corners get a fillet each,
        # so the outline never has a sharp angle: one for the outer edge, a wider one for the inner edge
        var fillOut, fillIn = ""
        let (wOut, wIn, f) = (rr + t, rr, 16.0)
        for k in 1 .. path.len - 2:
          let (p0, p1, p2) = (cellPos(path[k - 1]), cellPos(path[k]), cellPos(path[k + 1]))
          let a = vec((p1.x - p0.x) / cell, (p1.y - p0.y) / cell)
          let b = vec((p2.x - p1.x) / cell, (p2.y - p1.y) / cell)
          if abs(a.x * b.x + a.y * b.y) > 0.5: continue        # straight on: no corner
          for (w, r, inner) in [(wOut, f, false), (wIn, f + t, true)]:
            let kx = vec(p1.x + w * (b.x - a.x), p1.y + w * (b.y - a.y))   # the concave corner of this edge
            let s1 = vec(kx.x - a.x * r, kx.y - a.y * r)
            let s2 = vec(kx.x + b.x * r, kx.y + b.y * r)
            let piece = &"M{kx.x:.1f},{kx.y:.1f}L{s1.x:.1f},{s1.y:.1f}Q{kx.x:.1f},{kx.y:.1f} {s2.x:.1f},{s2.y:.1f}Z"
            if inner: fillIn.add piece
            else: fillOut.add piece
        let m = &"{maskTag}{i}"
        result.add &"""<mask id="{m}" maskUnits="userSpaceOnUse" x="0" y="0" width="600" height="650">""" &
          &"""<path d="{d}" class="wm" stroke="#fff" stroke-width="{2 * wOut:.1f}"/><path d="{fillOut}" fill="#fff"/>""" &
          &"""<path d="{d}" class="wm" stroke="#000" stroke-width="{2 * wIn:.1f}"/><path d="{fillIn}" fill="#000"/></mask>""" &
          &"""<rect class="wf {ink}" x="0" y="0" width="600" height="650" mask="url(#{m})"/>"""
    if coachTarget >= 0:
      let p = cellPos(coachTarget)
      result.add &"""<rect class="aim pulse" x="{p.x - 37}" y="{p.y - 37}" width="74" height="74" rx="12"/>"""

  proc staticSvg(b: Board): string =
    maskTag = "sm"
    result = """<svg viewBox="40 -10 520 520"><defs><filter id="rough2"><feTurbulence type="fractalNoise" baseFrequency=".035" numOctaves="2" seed="7"/><feDisplacementMap in="SourceGraphic" scale="5"/></filter><filter id="cutout2"><feTurbulence type="fractalNoise" baseFrequency=".012" numOctaves="1" seed="3"/><feDisplacementMap in="SourceGraphic" scale="9"/></filter></defs>""" & backdrop(b)
    for it in renderBoard(b):
      if b.cells.find(parseInt(it.key[1 .. ^1])) >= 0:
        result.add &"""<g transform="translate({it.pos.x},{it.pos.y})">{it.svg}</g>"""
    result.add overlay(b) & "</svg>"
    maskTag = "wm"

nbCode:
  let solution = puz.boardOf(puz.solve[0])
  let spoiler = "<details class=\"spoiler\"><summary>spoiler: the solved first puzzle, drawn by nimib at build time</summary>" &
    solution.staticSvg & "</details>"
nbRawHtml: spoiler

nbRawHtml: """<h2><span class="num">05 · THE RUNTIME</span>Pointer events in, pick calls out</h2>"""

nbText: """
The browser runtime (`std/dom`) keeps one SVG group per tile key, so a CSS transition slides tiles to their new
places whenever the shown board changes. While a tile is held it floats under the pointer, everything else shows
the picked future, and on release that future is committed.
"""

nbRawHtml: "<details><summary>show the browser runtime (std/dom, ~100 lines)</summary>"
nbCodeDisplay(nbJsFromCode):
  import std/[dom, tables]

  proc svgNode(tag: cstring): Element {.importjs: "document.createElementNS('http://www.w3.org/2000/svg', #)".}
  proc capture(e: Element, ev: Event) {.importjs: "#.setPointerCapture(#.pointerId)".}
  proc keyAt(ev: Event): cstring {.importjs: "(#.target.closest('[data-key]')?.dataset.key ?? null)".}
  proc setStyle(e: Element, k, v: cstring) {.importjs: "#.style.setProperty(#, #)".}
  proc checked(e: Element): bool {.importjs: "#.checked".}
  proc clientXY(ev: Event): Vec {.importjs: "(e => ({x: e.clientX, y: e.clientY}))(#)".}
  proc rectOf(e: Element): (float, float, float, float) {.importjs:
    "(() => { const r = #.getBoundingClientRect(); return {Field0: r.left, Field1: r.top, Field2: r.width, Field3: r.height}; })()".}

  type Stage[S] = ref object
    state: S
    render: Render[S]
    spec: proc (s: S, key: string): Behavior[S]
    backdrop, overlay: proc (s: S): string
    svg, bg, fg, top, ghosts: Element
    nodes: Table[string, Element]
    looks: Table[string, string]
    dragKey: string
    grab, at: Vec
    picker: Picker[S]
    choice: Choice[S]
    showGhosts: bool
    onCommit: proc ()
    onMove: proc ()               # after every pointer move and drop: effects drawn outside the view

  proc tr(p: Vec): cstring = cstring(&"translate({p.x:.2f}px, {p.y:.2f}px)")

  proc drawGhosts[S](st: Stage[S]) =
    var g = ""
    if st.dragKey.len > 0:
      if st.showGhosts:
        for l in st.picker.lands:
          if l.x == l.x: g.add &"""<circle class="land" cx="{l.x}" cy="{l.y}" r="6"/>"""
      if st.choice.ok:
        let c = st.choice.land
        g.add &"""<rect class="target" x="{c.x - 36}" y="{c.y - 36}" width="72" height="72" rx="13"/>"""
        if st.showGhosts:
          g.add &"""<line class="tether" x1="{st.at.x}" y1="{st.at.y}" x2="{c.x}" y2="{c.y}"/>"""
    st.ghosts.innerHTML = cstring(g)

  proc draw[S](st: Stage[S], s: S) =
    st.bg.innerHTML = cstring(st.backdrop(s))
    for it in st.render(s):
      let held = it.key == st.dragKey
      var n = st.nodes.getOrDefault(it.key)
      if n.isNil:
        n = svgNode("g")
        n.setAttribute("data-key", cstring(it.key))
        n.setStyle("transform", tr(it.pos))
        st.fg.appendChild(n)
        st.nodes[it.key] = n
      if st.looks.getOrDefault(it.key) != it.svg:
        n.innerHTML = cstring(it.svg)
        st.looks[it.key] = it.svg
      let grab = if st.spec(s, it.key).isNil: "" else: " grab"
      let lifted = if held: " lifted" else: ""
      let pos = if held: st.at else: it.pos
      n.setAttribute("class", cstring("item" & grab & lifted))
      n.setStyle("transform", tr(pos))
    st.top.innerHTML = cstring(st.overlay(s))
    st.drawGhosts()

  proc move[S](st: Stage[S], p: Vec) =
    st.at = p - st.grab
    st.choice = st.picker.pick(st.at)
    let shown = if st.choice.ok: st.choice.state else: st.state
    st.draw(shown)
    if not st.onMove.isNil: st.onMove()

  proc start[S](st: Stage[S], key: string, p: Vec) =
    let behavior = st.spec(st.state, key)
    if behavior.isNil: return
    st.dragKey = key
    st.grab = p - st.render.locate(st.state, key)
    st.picker = behavior(st.render, key)   # speculative renders happen here
    st.fg.appendChild(st.nodes[key])       # float above the others
    st.move(p)

  proc finish[S](st: Stage[S]) =
    if st.dragKey.len == 0: return
    if st.choice.ok: st.state = st.choice.state
    st.dragKey = ""
    st.draw(st.state)                      # the held tile glides home
    if not st.onMove.isNil: st.onMove()
    if not st.onCommit.isNil: st.onCommit()

  proc setState[S](st: Stage[S], s: S) =
    st.state = s
    st.draw(s)
    if not st.onCommit.isNil: st.onCommit()

  proc mount[S](host: Element, w, h: float, init: S, render: Render[S],
                spec: proc (s: S, key: string): Behavior[S],
                backdrop, overlay: proc (s: S): string): Stage[S] =
    host.innerHTML = cstring(&"""<svg class="d2" viewBox="0 0 {w} {h}"><defs><filter id="rough"><feTurbulence type="fractalNoise" baseFrequency=".035" numOctaves="2" seed="7"/><feDisplacementMap in="SourceGraphic" scale="5"/></filter><filter id="cutout"><feTurbulence type="fractalNoise" baseFrequency=".012" numOctaves="1" seed="3"/><feDisplacementMap in="SourceGraphic" scale="9"/></filter></defs><g class="bg"></g>""" &
      """<g class="fg"></g><g class="overlay"></g><g class="ghosts"></g></svg>""" &
      """<label class="ghost-toggle"><input type="checkbox"> <span data-it="mostra il meccanismo">show machinery</span></label>""")
    let st = Stage[S](state: init, render: render, spec: spec, backdrop: backdrop, overlay: overlay)
    st.svg = host.querySelector("svg")
    st.bg = host.querySelector(".bg")
    st.fg = host.querySelector(".fg")
    st.top = host.querySelector(".overlay")
    st.ghosts = host.querySelector(".ghosts")
    let toLocal = proc (ev: Event): Vec =
      let (l, t, rw, rh) = rectOf(st.svg)
      let c = clientXY(ev)
      vec((c.x - l) * w / rw, (c.y - t) * h / rh)
    st.svg.addEventListener("pointerdown", proc (ev: Event) =
      let k = keyAt(ev)
      if k.isNil: return
      ev.preventDefault()
      capture(st.svg, ev)
      st.start($k, toLocal(ev)))
    st.svg.addEventListener("pointermove", proc (ev: Event) =
      if st.dragKey.len > 0: st.move(toLocal(ev)))
    st.svg.addEventListener("pointerup", proc (ev: Event) = st.finish())
    st.svg.addEventListener("pointercancel", proc (ev: Event) = st.finish())
    let box = host.querySelector(".ghost-toggle input")
    box.addEventListener("change", proc (ev: Event) =
      st.showGhosts = box.checked
      st.drawGhosts())
    st.draw(init)
    st
nbRawHtml: "</details>"

# ---------------------------------------------------------------- the game wiring (hidden)
var codes = ""
for (title, code) in builtin: codes.add "<option value=\"" & code & "\">" & title & "</option>"
nbRawHtml: "<template id=\"builtin\">" & codes & "</template>"

nbJsFromCode:
  proc now(): float {.importjs: "Date.now()".}
  proc every(cb: proc (), ms: int) {.importjs: "setInterval(#, #)".}
  proc search(): cstring {.importjs: "String(location.search)".}
  proc pageUrl(): cstring {.importjs: "(location.origin + location.pathname)".}
  proc pushQuery(q: cstring) {.importjs: "history.replaceState(null, '', '?' + #)".}
  proc lsGet(k: cstring): cstring {.importjs: "(k => { try { return localStorage.getItem(k) } catch (e) { return null } })(#)".}
  proc lsSet(k, v: cstring) {.importjs: "((k, v) => { try { localStorage.setItem(k, v) } catch (e) {} })(#, #)".}
  proc copyText(s: cstring) {.importjs: "(s => { try { navigator.clipboard.writeText(s) } catch (e) {} })(#)".}
  proc rnd(): float {.importjs: "Math.random()".}
  proc attr(e: Element, k: cstring): cstring {.importjs: "#.getAttribute(#)".}
  proc options(): seq[Element] {.importjs: "Array.from(document.getElementById('builtin').content.querySelectorAll('option'))".}
  proc hoverIndex(ev: Event): cstring {.importjs: "(#.target.closest('[data-clue]')?.dataset.clue ?? null)".}
  proc navLang(): cstring {.importjs: "String(navigator.language || 'en')".}
  proc i18nNodes(): seq[Element] {.importjs: "Array.from(document.querySelectorAll('[data-it]'))".}
  proc setAttr(e: Element, k, v: cstring) {.importjs: "#.setAttribute(#, #)".}
  proc setDocLang(l: cstring) {.importjs: "document.documentElement.lang = #".}
  proc setHidden(e: Element, h: bool) {.importjs: "#.hidden = #".}
  proc dataOf(ev: Event, k: cstring): cstring {.importjs: "((e, k) => e.target.closest('[data-' + k + ']')?.getAttribute('data-' + k) ?? null)(#, #)".}

  let host = document.getElementById("board")
  let cluesEl = document.getElementById("clues")
  let pickerEl = document.getElementById("picker")
  var games: seq[(string, string)]
  for o in options(): games.add ($o.attr("value"), $o.innerHTML)
  var code = games[0][0]
  let fromUrl = $search()
  if fromUrl.contains("p=") and decode(fromUrl).valid:
    code = decode(fromUrl).encode
    if games.allIt(it[0] != code): games.add (code, "")
  # language: ?lang=, then the last choice, then the browser's
  let savedLang = lsGet("parloku:lang")
  lang = if ($navLang()).startsWith("it"): "it" else: "en"
  if not savedLang.isNil and $savedLang in ["en", "it"]: lang = $savedLang
  if fromUrl.contains("lang=it"): lang = "it"
  if fromUrl.contains("lang=en"): lang = "en"

  var solution: Grid
  var started = 0.0
  var wonAt = 0.0
  var celebrated = false

  proc emptyBoard(): Board = puz.boardOf(puz.startGrid)
  puz = decode(code)
  let stage = mount(host, 600, 612, emptyBoard(), renderBoard, tileSpec, backdrop, overlay)
  block:
    let slot = document.getElementById("machinery-slot")
    let toggle = host.querySelector(".ghost-toggle")
    if slot.isNil: toggle.setHidden(true)
    else: slot.appendChild(toggle)
  # ---- tiles that divide (after the garden devlog): pulling a copy off its letter grows a neck until it splits off;
  # bringing a tile back reaches out to its letter and the two merge. Drawn under the tiles, from the stage's pick.
  proc later(cb: proc (), ms: int) {.importjs: "setTimeout(#, #)".}
  func mul(v: Vec, k: float): Vec = vec(v.x * k, v.y * k)
  func waist(d, r: float): float =
    ## half-width of the neck between two tiles of radius r whose centres are d apart
    let t = clamp((d - 0.4 * r) / (4.2 * r), 0.0, 1.0)
    r * (0.85 - 0.74 * t)
  func neckPath(c1, c2: Vec, r, hw: float): string =
    ## an SVG path joining two circles of radius r with a waist of half-width hw
    let d = norm(c2 - c1)
    if d < 0.2 * r or hw < 0.3: return ""
    let u = mul(c2 - c1, 1 / d)
    let n = vec(-u.y, u.x)
    let a = arcsin(min(0.94, 1.05 * hw / r + 0.32))
    let m = c1 + mul(u, d / 2)
    var side: array[2, string]
    for k, sgn in [1.0, -1.0]:
      let p1 = c1 + mul(mul(u, cos(a)) + mul(n, sgn * sin(a)), r)
      let t1 = mul(u, sin(a)) - mul(n, sgn * cos(a))
      let p2 = c2 + mul(mul(u, -cos(a)) + mul(n, sgn * sin(a)), r)
      let t2 = mul(u, -sin(a)) - mul(n, sgn * cos(a))
      let w = m + mul(n, sgn * hw)
      let l = norm(p1 - w) * 0.5
      let h = clamp(1.4 * (r * sin(a) - hw) / max(cos(a), 0.2), 1.0, l)
      let (q1, q2, q3, q4) = (p1 + mul(t1, h), w - mul(u, l), w + mul(u, l), p2 + mul(t2, h))
      if k == 0:
        side[k] = &"M{c1.x:.1f} {c1.y:.1f}L{p1.x:.1f} {p1.y:.1f}C{q1.x:.1f} {q1.y:.1f} {q2.x:.1f} {q2.y:.1f} {w.x:.1f} {w.y:.1f}" &
          &"C{q3.x:.1f} {q3.y:.1f} {q4.x:.1f} {q4.y:.1f} {p2.x:.1f} {p2.y:.1f}L{c2.x:.1f} {c2.y:.1f}"
      else:
        side[k] = &"L{p2.x:.1f} {p2.y:.1f}C{q4.x:.1f} {q4.y:.1f} {q3.x:.1f} {q3.y:.1f} {w.x:.1f} {w.y:.1f}" &
          &"C{q2.x:.1f} {q2.y:.1f} {q1.x:.1f} {q1.y:.1f} {p1.x:.1f} {p1.y:.1f}Z"
    side[0] & side[1]

  let necks = svgNode("g")
  necks.setAttribute("class", "necks")
  stage.svg.insertBefore(necks, stage.fg)
  let fx = svgNode("g")
  fx.setAttribute("class", "fx")
  stage.svg.insertBefore(fx, stage.fg)
  var joined = false
  proc ripple(at: Vec, li: int) =
    ## the letter left behind wobbles when its copy splits off
    let e = svgNode("circle")
    e.setAttribute("class", cstring(&"ripple g{li}"))
    e.setAttribute("cx", cstring($at.x))
    e.setAttribute("cy", cstring($at.y))
    e.setAttribute("r", "32")
    fx.appendChild(e)
    later(proc () = fx.removeChild(e), 500)
  stage.onMove = proc () =
    let held = stage.dragKey
    var d = ""
    var li = 0
    var pulling = false
    if held.len > 0:
      let id = parseInt(held[1 .. ^1])
      li = id div 6
      let fromCell = stage.state.cells.find(id)
      let home = stackPos(li)
      let dd = norm(stage.at - home)
      let atHome = stage.choice.ok and stage.choice.state.cells.find(id) < 0
      var others = false                 # copies left under the held one: then it divides, else it moves whole
      for k in 0 .. 5:
        if li * 6 + k != id and stage.state.cells.find(li * 6 + k) < 0: others = true
      if fromCell < 0 and others and atHome:
        pulling = true
        d = neckPath(home, stage.at, 31, waist(dd, 31))
      elif fromCell >= 0 and atHome and dd < 2.6 * cell:
        d = neckPath(stage.at, home, 31, waist(dd, 31))
      if joined and not pulling and fromCell < 0 and others: ripple(home, li)
    joined = pulling
    if d.len > 0: necks.innerHTML = cstring(&"""<path class="neck g{li}" d="{d}"/>""")
    else: necks.innerHTML = ""

  # ---- on the game page, only the game: tap an empty spot to show the rest, and again to hide it
  proc interactive(ev: Event): bool {.importjs:
    "!!#.target.closest('button,a,input,label,select,summary,.clues,.stage,.coach,.skins,.picker,.status,.sp')".}
  proc scrollTop() {.importjs: "window.scrollTo(0, 0)".}
  proc inPlay(ev: Event): bool {.importjs: "!!#.target.closest('.play')".}
  proc setMode(m: string) =
    for k in ["focus", "chrome", "explain"]:
      if k == m: document.body.classList.add(cstring(k))
      else: document.body.classList.remove(cstring(k))
  let playEl = document.getElementById("play")
  if not playEl.isNil:
    setMode("focus")
    let moreBtn = document.getElementById("more")
    moreBtn.setHidden(false)
    moreBtn.addEventListener("click", proc (ev: Event) =
      setMode("explain")
      document.querySelector(".rules").scrollIntoView())
    document.addEventListener("click", proc (ev: Event) =
      if interactive(ev): return
      if document.body.classList.contains("focus"): setMode("chrome")
      elif document.body.classList.contains("chrome"): setMode("focus")
      elif inPlay(ev):
        setMode("focus")
        scrollTop())

  let banner = document.createElement("div")
  banner.className = "banner"
  host.appendChild(banner)
  let confetti = document.createElement("div")
  confetti.className = "confetti"
  host.appendChild(confetti)

  proc clock(): string =
    let t0 = if wonAt > 0: wonAt else: now()
    let s = if started > 0: int((t0 - started) / 1000) else: 0
    &"{s div 60}:{s mod 60:02}"


  proc showClues() =
    let g = stage.state.grid
    var html = ""
    for i, clue in puz.clues:
      let path = g.trace(clue)
      let full = path.len == clue.word.len
      let cls = if full: " done" else: ""
      let foc = if focusClue == i: " focus" else: ""
      html.add &"""<div class="clue{cls}{foc}" data-clue="{i}" style="border-color:var(--w{i mod 3})">"""
      for k, ch in clue.word:
        let li = puz.letters.find(ch)
        if k < path.len:
          html.add &"""<span class="l on" style="background:var(--g{li});color:var(--i{li})">{ch}</span>"""
        else:
          html.add &"""<span class="l">{ch}</span>"""
      let tick = if full: "✓" else: ""
      html.add &"""<span class="ok">{tick}</span></div>"""
    cluesEl.innerHTML = cstring(html)

  var tutorial = false                 # the 🎓 tutorial runs on the first puzzle, with its own saved board
  proc storeKey(): cstring =
    let prefix = if tutorial: "parloku:tutorial:" else: "parloku:"
    cstring(prefix & code)
  proc save() =
    lsSet(storeKey(), cstring(stage.state.cells.join(",") & ";" & $stage.state.moves & ";" & $started & ";" & $wonAt))

  proc celebrate() =
    var bits = ""
    for k in 0 ..< 60:
      let li = int(rnd() * 6) mod 6
      let x = int(rnd() * 100)
      let dx = int(rnd() * 160) - 80
      let r = int(rnd() * 720) - 360
      let t = 1.6 + rnd() * 1.6
      let d = rnd() * 0.6
      bits.add &"""<i style="--x:{x}%;--dx:{dx}px;--r:{r}deg;--t:{t:.2f}s;--d:{d:.2f}s;background:var(--g{li});color:var(--i{li})">{puz.letters[li]}</i>"""
    confetti.innerHTML = cstring(bits)

  let coachEl = document.getElementById("coach")
  let coachHd = document.getElementById("coach-hd")
  let coachText = document.getElementById("coach-text")
  let coachActs = document.getElementById("coach-acts")
  var intro = 0                        # 0 .. 3: the intro pages, 4: solving
  var guided = true                    # false once the player chose to finish the sudoku alone
  var wordsAck = false                 # the "all words are in" page was seen
  var coachStep: Step
  proc showCoach()
  proc refresh() =
    let g = stage.state.grid
    let won = solved(puz, g)
    if won and wonAt == 0: wonAt = now()
    if won and not celebrated:
      celebrated = true
      banner.innerHTML = cstring(&"<b>Bravo!</b><span>{stage.state.moves} " & L("moves", "mosse") & &" · {clock()}</span>")
      celebrate()
    if won: host.classList.add("won")
    else: host.classList.remove("won")
    showClues()
    showCoach()

  var history: seq[Board]               # boards before each change, for ↶ undo
  var last = stage.state
  let undoBtn = document.getElementById("undo")
  proc setDisabled(e: Element, d: bool) {.importjs: "#.disabled = #".}
  stage.onCommit = proc () =
    if started == 0 and stage.state.moves > 0: started = now()
    if stage.state.cells != last.cells:
      history.add last
      last = stage.state
    undoBtn.setDisabled(history.len == 0)
    refresh()
    save()

  proc load(c: string) =
    code = c
    puz = decode(c)
    let sols = puz.solve(limit = 1)
    for i in 0 ..< 36: solution[i] = '.'
    if sols.len > 0: solution = sols[0]
    var b = emptyBoard()
    started = 0
    wonAt = 0
    let saved = lsGet(storeKey())
    if not saved.isNil:
      let parts = ($saved).split(';')
      let cells = parts[0].split(',')
      if parts.len == 4 and cells.len == 36:
        for i in 0 ..< 36: b.cells[i] = parseInt(cells[i])
        b.moves = parseInt(parts[1])
        started = parseFloat(parts[2])
        wonAt = parseFloat(parts[3])
    celebrated = solved(puz, b.grid)     # don't throw confetti again on reload
    confetti.innerHTML = ""
    banner.innerHTML = cstring(&"<b>Bravo!</b><span>{b.moves} " & L("moves", "mosse") & &" · {clock()}</span>")
    var html = ""
    for i, (gc, title) in games:
      let on = if gc == c and not tutorial: " on" else: ""
      let name = if title == "": L("from the link", "dal link") else: title
      html.add &"""<button class="btn num{on}" data-i="{i}" title="{name}" aria-label="{L("puzzle", "puzzle")} {i + 1}: {name}">{i + 1}</button>"""
    pickerEl.innerHTML = cstring(html)
    stage.setState(b)
    history = @[]
    last = stage.state
    undoBtn.setDisabled(true)


  proc dataI(ev: Event): cstring {.importjs: "(#.target.closest('[data-i]')?.dataset.i ?? null)".}
  pickerEl.addEventListener("click", proc (ev: Event) =
    let i = dataI(ev)
    if not i.isNil:
      if not playEl.isNil: setMode("focus")
      tutorial = false
      load(games[parseInt($i)][0])
      pushQuery(cstring("p=" & code)))

  let resetBtn = document.getElementById("reset")
  var armed = 0.0                      # reset wipes the board: the first tap only asks "sure?"
  resetBtn.addEventListener("click", proc (ev: Event) =
    if stage.state.cells.allIt(it < 0) or (armed > 0 and now() - armed < 3000):
      armed = 0
      resetBtn.innerHTML = cstring(L("↺<span class='tx'> reset</span>", "↺<span class='tx'> ricomincia</span>"))
      lsSet(storeKey(), "")
      load(code)
    else:
      armed = now()
      resetBtn.innerHTML = cstring(L("↺ sure?", "↺ sicuro?")))
  every(proc () =
    if armed > 0 and now() - armed >= 3000:
      armed = 0
      resetBtn.innerHTML = cstring(L("↺<span class='tx'> reset</span>", "↺<span class='tx'> ricomincia</span>")), 500)

  undoBtn.addEventListener("click", proc (ev: Event) =
    if history.len == 0: return
    last = history.pop
    stage.setState(last))

  document.getElementById("share").addEventListener("click", proc (ev: Event) =
    let url = $pageUrl() & "?p=" & code
    copyText(cstring(url))
    pushQuery(cstring("p=" & code))
    let btn = document.getElementById("share")
    btn.innerHTML = cstring(L("✓ copied", "✓ copiato")))

  proc placeCorrect(c: int) =
    ## glide a tile of the right letter into cell `c`: one still on its stack, else one sitting in a wrong cell
    let b = stage.state
    let g = b.grid
    let li = puz.letters.find(solution[c])
    if li < 0: return
    var id = -1
    for k in 0 .. 5:
      if id < 0 and b.cells.find(li * 6 + k) < 0: id = li * 6 + k
    for k in 0 .. 5:
      let at = b.cells.find(li * 6 + k)
      if id < 0 and at >= 0 and g[at] != solution[at]: id = li * 6 + k
    if id < 0: return
    if started == 0: started = now()
    stage.setState(b.home(id).place(id, c))

  document.getElementById("hint").addEventListener("click", proc (ev: Event) =
    ## one correct tile glides in, into an empty or wrong cell
    let g = stage.state.grid
    var wrong: seq[int]
    for c in 0 ..< 36:
      if solution[c] != '.' and g[c] != solution[c]: wrong.add c
    if wrong.len > 0: placeCorrect(wrong[int(rnd() * wrong.len.float) mod wrong.len]))

  cluesEl.addEventListener("pointerover", proc (ev: Event) =
    let i = hoverIndex(ev)
    let f = if i.isNil: -1 else: parseInt($i)
    if f != focusClue:
      focusClue = f
      stage.top.innerHTML = cstring(overlay(stage.state)))
  var pinnedClue = -1                  # a tapped clue stays highlighted: phones have no hover
  cluesEl.addEventListener("pointerleave", proc (ev: Event) =
    focusClue = pinnedClue
    stage.top.innerHTML = cstring(overlay(stage.state)))
  cluesEl.addEventListener("click", proc (ev: Event) =
    let i = hoverIndex(ev)
    let f = if i.isNil: -1 else: parseInt($i)
    pinnedClue = if f == pinnedClue: -1 else: f
    focusClue = pinnedClue
    showClues()
    stage.top.innerHTML = cstring(overlay(stage.state)))

  # ---- the 🎓 tutorial: a coach above the board that asks the logical path for the next move after every drop

  proc buttons(acts: seq[(string, string)]): string =
    for (act, label) in acts: result.add &"""<button class="btn" data-act="{act}">{label}</button>"""

  proc introText(): string =
    case intro
    of 0: L("Welcome! This is the first Parloku. Fill the grid with the six letters <b>A I L P S T</b>, pulling copies out of the six letters below the board.",
            "Benvenuto! Questo è il primo Parloku. Riempi la griglia con le sei lettere <b>A I L P S T</b>, tirando fuori delle copie dalle sei lettere sotto la griglia.")
    of 1: L("As in sudoku, each letter appears once in every row, every column and every 2×3 box. One of each is highlighted.",
            "Come nel sudoku, ogni lettera compare una volta in ogni riga, in ogni colonna e in ogni riquadro 2×3. Ne vedi evidenziato uno per tipo.")
    of 2: L("The three words above are the clues. Each one starts in the cell ringed in its colour and goes one step at a time: up, down, left or right.",
            "Le tre parole in alto sono gli indizi. Ognuna parte dalla casella con il cerchio del suo colore e procede un passo alla volta: in su, in giù, a destra o a sinistra.")
    else: L("The method: first put the first letter of every word. Then follow each word letter by letter. When the sudoku leaves only one cell for the next letter, that letter is forced. Let's start!",
            "Il metodo: prima metti la prima lettera di ogni parola. Poi segui ogni parola lettera per lettera. Quando il sudoku lascia una sola casella per la lettera dopo, quella lettera è obbligata. Cominciamo!")

  proc showCoach() =
    coachTint = @[]
    coachTarget = -1
    coachStacks = @[]
    if tutorial: host.classList.add("tutoring")
    else: host.classList.remove("tutoring")
    if not tutorial:
      coachEl.setHidden(true)
      stage.draw(stage.state)
      return
    coachEl.setHidden(false)
    let g = stage.state.grid
    var text = ""
    var acts: seq[(string, string)]
    let filled = toSeq(0 ..< 36).countIt(g[it] != '.')
    coachHd.innerHTML = cstring(L("🎓 TUTORIAL", "🎓 TUTORIAL") & &" · {filled}/36")
    if intro < 4:
      text = introText()
      acts = @[("next", L("next →", "avanti →")), ("exit", L("exit", "esci"))]
      if intro == 0: coachStacks = toSeq(0 .. 5)
      if intro == 1: coachTint = units[2] & units[10] & units[12]
      if intro == 2: coachTint = puz.clues.mapIt(idx(it.pos))
    elif solved(puz, g):
      text = L("<b>Bravo, solved!</b> Now try puzzle 2, AMICA · GIOCO · MAGIA, on your own: the same method works.",
               "<b>Bravo, risolto!</b> Ora prova da solo il puzzle 2, AMICA · GIOCO · MAGIA: il metodo è lo stesso.")
      acts = @[("exit", L("close", "chiudi"))]
    else:
      let s = logicalStep(puz, g, solution)
      coachStep = s
      if s.kind in {skNaked, skHidden, skReveal} and not wordsAck:
        text = L("<b>All three words are in!</b> The rest is plain sudoku: from now on, every move is a cell with only one letter left. I can keep guiding you, or you can finish on your own.",
                 "<b>Le tre parole sono al loro posto!</b> Il resto è sudoku puro: da qui in poi ogni mossa è una casella con una sola lettera possibile. Posso continuare a guidarti, oppure puoi finire da solo.")
        acts = @[("guide", L("keep guiding me", "continua a guidarmi")), ("alone", L("on my own", "faccio da solo"))]
      elif not guided and s.kind != skFix:
        coachEl.setHidden(true)
      else:
        text = explain(puz, g, s)
        if s.kind != skFix:
          text.add L(&" Drag {an(s.letter)} <b>{s.letter}</b> there.", &" Trascina lì una <b>{s.letter}</b>.")
          coachStacks = @[puz.letters.find(s.letter)]
        coachTarget = s.cell
        case s.kind
        of skWord: coachTint = neighbours(s.path[^2]).filterIt(it != s.cell and it notin s.path)
        of skNaked: coachTint = peersOf[s.cell]
        of skHidden: coachTint = units[s.unit]
        else: discard
        acts = @[("show", L("show me", "fammi vedere")), ("exit", L("exit", "esci"))]
    coachText.innerHTML = cstring(text)
    coachActs.innerHTML = cstring(buttons(acts))
    stage.draw(stage.state)

  proc startTutorial() =
    tutorial = true
    intro = 0
    guided = true
    wordsAck = false
    code = games[0][0]
    lsSet(storeKey(), "")
    load(code)
    document.getElementById("coach").scrollIntoView()

  coachActs.addEventListener("click", proc (ev: Event) =
    let act = dataOf(ev, "act")
    if act.isNil: return
    case $act
    of "next": inc intro
    of "guide": wordsAck = true
    of "alone":
      wordsAck = true
      guided = false
    of "show":
      let s = coachStep
      if s.kind == skFix:
        let b = stage.state
        stage.setState(b.home(b.cells[s.cell]))
      elif s.cell >= 0: placeCorrect(s.cell)
      return                           # setState already asked the coach for the next step
    of "exit":
      tutorial = false
      load(code)
      return
    else: discard
    showCoach())

  document.getElementById("tutorial").addEventListener("click", proc (ev: Event) =
    if not playEl.isNil: setMode("focus")
    startTutorial())

  # ---- English / Italian
  let langsEl = document.getElementById("langs")
  proc applyLang() =
    setDocLang(cstring(lang))
    lsSet("parloku:lang", cstring(lang))
    for e in i18nNodes():
      if e.attr("data-en").isNil: e.setAttr("data-en", e.innerHTML)
      e.innerHTML = e.attr(cstring("data-" & lang))
    for b in langsEl.querySelectorAll("button"):
      if $b.attr("data-lang") == lang: b.classList.add("on")
      else: b.classList.remove("on")
    load(code)
  langsEl.addEventListener("click", proc (ev: Event) =
    let l = dataOf(ev, "lang")
    if l.isNil: return
    lang = $l
    applyLang())

  # ---- skins: the look of the page, remembered per browser, or ?skin=name
  proc setSkin(e: Element, v: cstring) {.importjs: "#.dataset.skin = #".}
  let skinsEl = document.getElementById("skins")
  proc applySkin(name: string) =
    document.body.setSkin(cstring(name))
    lsSet("parloku:look", cstring(name))
    for b in skinsEl.querySelectorAll("button"):
      if $b.attr("data-skin") == name: b.classList.add("on")
      else: b.classList.remove("on")
  var skin = "niki"
  let savedSkin = lsGet("parloku:look")
  if not savedSkin.isNil and ($savedSkin).len > 0: skin = $savedSkin
  let si = fromUrl.find("skin=")
  if si >= 0: skin = fromUrl[si + 5 .. ^1].split('&')[0]
  applySkin(skin)
  skinsEl.addEventListener("click", proc (ev: Event) =
    let k = dataOf(ev, "skin")
    if not k.isNil: applySkin($k))

  if fromUrl.contains("tutorial"):
    tutorial = true
    code = games[0][0]
  applyLang()

nbText: """
That's the game. Puzzles live in [`data/`](https://github.com/pietroppeter/parloku/tree/main/data) as puzzlepaw JSON,
and any puzzle can be played from a link such as `?p=AILPST_01S.33L.54P_50ITALIA.30PASTA.10ALPI`
(the 🔗 button copies it). Progress is kept in your browser, per puzzle.
The game speaks English and Italian (EN / IT at the top, or `?lang=it`), and `?tutorial` opens the 🎓 tutorial directly.

Built with [nimib](https://github.com/pietroppeter/nimib). Hit *show source* below for the whole notebook.
"""

nbSave
