## The Parloku builder: the game's board, tiles and gestures, used to make a puzzle.
## Pick three words, drag each word's ring onto the board and lengthen it letter by letter, play on, and pin some letters as clues. The pencil marks and the solution count come from
## `solver.nim` (moved here from puzzlepaw), compiled to JS with the page.
##
## The explanations live in builder_howto.nim (builder-howto.html), so this page stays compact.
## The model, rules, drag engine, view and runtime blocks are copied from `parloku.nim` (the game), so the
## builder looks and feels the same; only the builder wiring at the end is new. Writes builder.html.
import std/[algorithm, json, os, strformat, strutils]
import nimib
import style, builder_style
import solver

nbInit
nb.doc.filename = currentSourcePath().parentDir.parentDir / "builder.html"
nb.doc.context["title"] = %"Parloku builder"
nb.doc.context["stylesheet"] = %(pageStyle & builderCss)
nb.doc.context["highlight"] = %""
nb.doc.context["disableHighlightJs"] = %true
func pageHeader(blk: JsonNode, nb: Nb): string = ""
nb.backend.partials["header"] = pageHeader

const pinIcon = """<svg class="pin" viewBox="-14 -20 28 40"><line x1="0" y1="0" x2="0" y2="18"/><circle cx="0" cy="-6" r="10"/><circle class="hi" cx="-3" cy="-9" r="3"/></svg>"""
nbRawHtml: """
<div class="bld" id="bld">
<div class="bar"><span class="logo" title="Parloku builder">P</span><div class="sets" id="sets"></div>
<button class="tool sm" id="edit" title="scrivi tre parole" aria-label="scrivi tre parole">✎</button>
<a class="tool sm" href="builder-howto.html" title="come funziona" aria-label="come funziona">?</a></div>
<div class="row custom" id="customrow" hidden><input id="custom" spellcheck="false" autocomplete="off" placeholder="tre parole, es. NERO ROSA ORO" aria-label="tre parole"><button class="btn" id="use">usa</button></div>
<div class="say" id="say"></div>
<div class="game">
  <div class="top"><div class="clues" id="clues"></div>
  <div class="tools">
    <span class="tool pinsrc" id="pinsrc" role="button" title="puntina: trascinala su una lettera per fissarla" aria-label="puntina">📌</span>
    <button class="tool" id="reset" title="ricomincia" aria-label="ricomincia">↺</button>
    <button class="tool" id="save" title="salva: copia il puzzle in JSON, con soluzione e stato del builder" aria-label="salva">💾</button>
    <button class="tool" id="link" title="copia il link per giocare" aria-label="link per giocare">🔗</button>
  </div></div>
  <div class="stage" id="board"></div>
  <div class="sols" id="sols" aria-label="soluzioni"></div>
</div>
<div hidden><button id="undo" disabled></button><span id="sol"></span><input type="checkbox" id="nou" checked><button id="dice"></button><div id="panel"></div></div>
</div>
"""

# Word triples: data/terne.txt, without the ones that already have a puzzle in data/.
proc tripleKey(words: seq[string]): string =
  var w = words
  w.sort()
  w.join(" ")
var made: seq[string]
for f in walkFiles(currentSourcePath().parentDir.parentDir / "data" / "puzzle*.json"):
  var words: seq[string]
  for h in parseFile(f)["problem"]["wordHints"]: words.add h["word"].getStr.toUpperAscii
  made.add tripleKey(words)
var terne: seq[string]
for line in lines(currentSourcePath().parentDir.parentDir / "data" / "terne.txt"):
  let t = line.strip.toUpperAscii
  if t.len == 0 or t.startsWith("#"): continue
  if tripleKey(t.splitWhitespace) notin made: terne.add t.splitWhitespace.join(" ")
nbRawHtml: "<template id=\"terne\">" & terne.join("|") & "</template>"

nbJsFromCode:
  import std/[math, strformat, strutils, sequtils, algorithm]

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
    for part in c.split('&'):              # a whole query string: take its p= value, wherever it is
      if part.startsWith("p="): c = part[2 .. ^1]
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

  proc trace(g: Grid, clue: Clue, wild = false, revisit = false, avoid: seq[int] = @[]): seq[int] =
    ## longest prefix of the word that can be walked from its start cell, never through a cell in `avoid`.
    ## A path never comes back to a cell it already used, or G-I-O-C would read as GIOCO by stepping back
    ## onto the O. (`revisit` lets it, and is kept only to compare the two rules.)
    if not revisit:
      var best, path: seq[int]
      let word = clue.word
      proc walk(cell, i: int) =
        if best.len == word.len or cell in path or cell in avoid: return
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
      return best
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

  proc othersStarts(clues: seq[Clue], i: int): seq[int] =
    for j, c in clues:
      if j != i: result.add idx(c.pos)

  proc outlines(g: Grid, clues: seq[Clue]): seq[seq[int]] =
    ## as in the game (src/parloku.nim): two words never share a cell
    result = newSeq[seq[int]](clues.len)
    var order = toSeq(0 ..< clues.len)
    let first = order.mapIt(g.trace(clues[it], avoid = othersStarts(clues, it)).len)
    order.sort(proc (a, b: int): int = (if first[a] != first[b]: first[b] - first[a] else: a - b))
    var claimed: seq[int]
    for i in order:
      result[i] = g.trace(clues[i], avoid = othersStarts(clues, i) & claimed)
      claimed.add result[i]

  proc solved(p: Puzzle, g: Grid): bool =
    if '.' in g or g.clashes.len > 0: return false
    let ls = g.outlines(p.clues)
    for i, clue in p.clues:
      if ls[i].len != clue.word.len: return false
    true

  proc solve(p: Puzzle, limit = 2): seq[Grid] =
    ## backtracking with "fewest candidates first", pruning on the clues;
    ## stops after `limit` solutions (2 is enough to tell unique from ambiguous)
    var g = startGrid(p)
    var sols: seq[Grid]
    proc fits(g: Grid, cell: int, ch: char): bool = peersOf[cell].allIt(g[it] != ch)
    proc cluesOk(g: Grid): bool =
      toSeq(0 ..< p.clues.len).allIt(g.trace(p.clues[it], wild = true, avoid = othersStarts(p.clues, it)).len == p.clues[it].word.len)
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
  # ---- builder state, read by the copied view code below
  var wpath: seq[seq[int]]        # each word's container: the cells it runs through, from its start (empty: not on the board)
  var marks: array[36, string]    # pencil marks: the letters each empty cell can still take
  var noneCell: array[36, bool]   # an empty cell with no letter left
  var growWord = -1               # the word being lengthened (its last letter is held)
  var growOpts: seq[int]          # where its next letter can go
  var slotOf = [0, 1, 2, 3, 4, 5]  # where each letter's stack sits below the board (reordered by the user)
  var solGrid: array[36, char]    # the solution shown in the empty cells ('.' = none)
  var solPaths: seq[seq[int]]     # its three words, cell by cell
  var solWord: array[36, int]     # the word whose path runs through each cell in that solution (-1 = none)
  for c in 0 ..< 36:
    solGrid[c] = '.'
    solWord[c] = -1

  const pinSvg = """<svg class="pin" viewBox="-14 -20 28 40"><line x1="0" y1="0" x2="0" y2="18"/><circle cx="0" cy="-6" r="10"/><circle class="hi" cx="-3" cy="-9" r="3"/></svg>"""

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
  ## colours live in the page's CSS skins: --g0..--g5 tile colours, --i0..--i5 their letters, --c0..--c4 the clues
  const cell = 78.0
  const bx = 66.0
  const by = 16.0

  proc cellPos(c: int): Vec = vec(bx + float(c mod 6) * cell + cell / 2, by + float(c div 6) * cell + cell / 2)
  proc slotPos(i: int): Vec = vec(150 + float(i mod 3) * 150, 546 + float(i div 3) * 74)   # two rows of three under the board
  proc stackPos(li: int): Vec = slotPos(slotOf[li])   # builder: the letters can be reordered

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
    var cls = "tile"
    if given: cls = "tile given"
    result = shapes(li, cls) &
      &"""<text y="13" text-anchor="middle" font-size="36" class="glyph i{li}">{letter}</text>"""
    if given: result.add """<g class="pinmark" transform="translate(22,-23) rotate(30)"><line x1="0" y1="0" x2="0" y2="13"/><circle cx="0" cy="-4" r="7"/></g>"""

  proc renderBoard(b: Board): seq[Item] =
    var at: array[36, int]
    for id in 0 ..< 36: at[id] = -1
    for c, id in b.cells:
      if id >= 0: at[id] = c
    let bad = b.grid.clashes             # letters in conflict tremble (CSS), more and more for a few seconds
    for id in 0 ..< 36:
      let c = at[id]
      let pos = if c >= 0: cellPos(c) else: stackPos(id div 6)
      var svg = tileSvg(id div 6, c >= 0 and isGiven(c))
      if c >= 0 and c in bad: svg = """<g class="shake">""" & svg & "</g>"
      result.add Item(key: &"t{id}", pos: pos, svg: svg)
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

  proc isHead(b: Board, at: int): bool =
    ## the letter on `at` is the last one spelled so far of some word: the head of its snake
    let g = b.grid
    let ls = g.outlines(puz.clues)
    for i, clue in puz.clues:
      let path = ls[i]
      if path.len > 0 and path[^1] == at: return true
    false

  proc tileSpec(b: Board, key: string): Behavior[Board] =
    let id = parseInt(key[1 .. ^1])
    let src = b.cells.find(id)
    if src >= 0 and isGiven(src): return nil
    var futures: seq[Board]
    for c in 0 ..< 36:                     # only empty cells: a tile never pushes out a letter already placed
      if not isGiven(c) and (b.cells[c] < 0 or c == src): futures.add b.place(id, c)
    var fallback = b.home(id)              # a tile from below goes back to its letter
    if src >= 0: fallback = b              # a tile lifted off the board stays in its cell
    closest(futures).within(cell * 0.6).orElse(closest(@[fallback]))
  var focusClue = -1             # the clue chip under the mouse, drawn bolder
  var wiggleClue = -1            # a tapped clue: its ring or outline on the board wiggles for a moment
  var maskTag = "wm"             # ids of the word-outline masks (the build-time spoiler uses its own)
  var coachTint: seq[int]        # tutorial: cells to tint (the reason for a step)
  var coachTarget = -1           # tutorial: the cell to fill (or empty)
  var coachStacks: seq[int]      # tutorial: letter stacks to make glow

  proc backdrop(b: Board): string =
    let g = b.grid
    result = &"""<rect class="frame" x="{bx - 9}" y="{by - 9}" width="{cell * 6 + 18}" height="{cell * 6 + 18}" rx="14"/>"""
    # a classic mini sudoku: one plain square, thin lines between cells, thick lines round the boxes and the edge
    result.add &"""<rect class="cell ca" x="{bx}" y="{by}" width="{cell * 6}" height="{cell * 6}"/>"""
    for c in coachTint:
      let p = cellPos(c)
      result.add &"""<rect class="cell tint" x="{p.x - cell/2}" y="{p.y - cell/2}" width="{cell}" height="{cell}"/>"""
    for c in 0 ..< 36:
      if noneCell[c] and b.cells[c] < 0:
        let p = cellPos(c)
        result.add &"""<rect class="cell bad" x="{p.x - cell/2}" y="{p.y - cell/2}" width="{cell}" height="{cell}"/>"""
    for i in 1 .. 5:
      result.add &"""<line class="thin" x1="{bx}" y1="{by + i.float * cell}" x2="{bx + cell * 6}" y2="{by + i.float * cell}"/>"""
      result.add &"""<line class="thin" x1="{bx + i.float * cell}" y1="{by}" x2="{bx + i.float * cell}" y2="{by + cell * 6}"/>"""
    result.add &"""<rect class="edge" x="{bx}" y="{by}" width="{cell * 6}" height="{cell * 6}"/>"""
    # builder: pencil marks in the empty cells; the letters of the three words in the solution shown take their word's colour
    for c in 0 ..< 36:
      if b.cells[c] < 0 and not noneCell[c]:
        let p = cellPos(c)
        for k, l in puz.letters:
          if l in marks[c]:
            var cls = "pm"
            if solWord[c] >= 0 and solGrid[c] == l: cls = &"pm on w{solWord[c] mod 3}"
            elif solGrid[c] == l: cls = "pm on sk"     # the rest of the solution, in black
            let s = slotOf[k]
            result.add &"""<text class="{cls}" x="{p.x - 22 + float(s mod 3) * 22:.0f}" y="{p.y - 6 + float(s div 3) * 24:.0f}" text-anchor="middle">{l}</text>"""
    for i in 1 .. 2:
      let y = by + i.float * cell * 2
      result.add &"""<rect class="boxline" x="{bx}" y="{y - 2.5}" width="{cell * 6}" height="5"/>"""
    result.add &"""<rect class="boxline" x="{bx + cell * 3 - 2.5}" y="{by}" width="5" height="{cell * 6}"/>"""
    for i in 0 .. 5:                 # row and column numbers, for the tutorial's r3c4
      result.add &"""<text x="{bx - 22}" y="{cellPos(i * 6).y + 5}" text-anchor="middle" font-size="14" class="mono lbl">r{i + 1}</text>"""
      result.add &"""<text x="{cellPos(i).x}" y="{by + cell * 6 + 28}" text-anchor="middle" font-size="14" class="mono lbl">c{i + 1}</text>"""
    for li in coachStacks:
      let s = stackPos(li)
      result.add &"""<rect class="glow pulse" x="{s.x - 38}" y="{s.y - 38}" width="76" height="76" rx="18"/>"""
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
    # builder: in the solution shown, a word not on the board yet gets a start mark on its first letter, in its colour
    for i in 0 ..< min(solPaths.len, puz.clues.len):
      if wpath[i].len == 0 and solPaths[i].len > 0:
        # a small, thin square round the word's first letter among the pencil marks (a big one would look like a word
        # placed on the board, which is the builder's own choice)
        let c = solPaths[i][0]
        let p = cellPos(c)
        let k = puz.letters.find(solGrid[c])
        if k < 0: continue
        let s = slotOf[k]
        let (x, y) = (p.x - 22 + float(s mod 3) * 22, p.y - 12 + float(s div 3) * 24)
        result.add &"""<rect class="wo w{i mod 3} solstart" x="{x - 10:.1f}" y="{y - 11:.1f}" width="20" height="22" rx="5" stroke-width="1.5"/>"""
    for i, clue in puz.clues:
      if wpath[i].len == 0: continue      # builder: a word's outline follows its container
      # each word is an outline in its own dark colour: a ring on its start cell that grows around its letters
      let path = wpath[i]
      let ink = &"w{i mod 3}"
      var t = 4.0
      if focusClue == i: t = 6.0
      # the outline stays inside its cells (3 units from each edge), so two words in cells side by side never touch
      let rr = cell / 2 - 3 - t
      let corner = 14.0                    # outer corner radius of the outline: rounded squares, as the word boxes
      if wiggleClue == i:
        var (sx, sy) = (0.0, 0.0)
        let cells = if path.len > 0: path else: @[idx(clue.pos)]
        for c in cells:
          sx += cellPos(c).x
          sy += cellPos(c).y
        result.add &"""<g class="wig" style="transform-origin:{sx / cells.len.float:.1f}px {sy / cells.len.float:.1f}px">"""
      if path.len <= 1:
        let p = cellPos(idx(clue.pos))
        let h = rr + t / 2                 # a rounded square, like the word's box above
        result.add &"""<rect class="wo {ink}" x="{p.x - h:.1f}" y="{p.y - h:.1f}" width="{2 * h:.1f}" height="{2 * h:.1f}" rx="{corner - t / 2:.1f}" stroke-width="{t}"/>"""
      else:
        var d = ""
        for k, c in path:
          let p = cellPos(c)
          let cmd = if k == 0: "M" else: "L"
          d.add &"{cmd}{p.x:.1f},{p.y:.1f} "
        # round stroke joins round the outer corners; the inner (concave) corners get a fillet each,
        # so the outline never has a sharp angle: one for the outer edge, a wider one for the inner edge
        var fillOut, fillIn = ""
        let (wOut, wIn, f) = (rr + t, rr, 10.0)
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
        # the outline is the union of a rounded square per cell and a band between each two cells in a row,
        # for the outer edge (white) and, cut out of it, for the inner edge (black)
        proc squares(w, r: float, col: string): string =
          for k, c in path:
            let p = cellPos(c)
            result.add &"""<rect x="{p.x - w:.1f}" y="{p.y - w:.1f}" width="{2 * w:.1f}" height="{2 * w:.1f}" rx="{r:.1f}" fill="{col}"/>"""
            if k > 0:
              let q = cellPos(path[k - 1])
              let (x0, y0) = (min(p.x, q.x), min(p.y, q.y))
              let (dx, dy) = (abs(p.x - q.x), abs(p.y - q.y))
              if dx > dy: result.add &"""<rect x="{x0:.1f}" y="{y0 - w:.1f}" width="{dx:.1f}" height="{2 * w:.1f}" fill="{col}"/>"""
              else: result.add &"""<rect x="{x0 - w:.1f}" y="{y0:.1f}" width="{2 * w:.1f}" height="{dy:.1f}" fill="{col}"/>"""
        let m = &"{maskTag}{i}"
        result.add &"""<mask id="{m}" maskUnits="userSpaceOnUse" x="0" y="0" width="600" height="650">""" &
          squares(wOut, corner, "#fff") & &"""<path d="{fillOut}" fill="#fff"/>""" &
          squares(wIn, corner - t, "#000") & &"""<path d="{fillIn}" fill="#000"/></mask>""" &
          &"""<rect class="wf {ink}" x="0" y="0" width="600" height="650" mask="url(#{m})"/>"""
      if wiggleClue == i: result.add "</g>"
    for c in growOpts:                    # builder: where a held word's next letter can go
      let p = cellPos(c)
      result.add &"""<rect class="opt w{growWord mod 3}" x="{p.x - cell * 0.4:.1f}" y="{p.y - cell * 0.4:.1f}" width="{cell * 0.8:.1f}" height="{cell * 0.8:.1f}" rx="12"/>"""
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
  import std/[dom, tables]

  proc svgNode(tag: cstring): Element {.importjs: "document.createElementNS('http://www.w3.org/2000/svg', #)".}
  proc capture(e: Element, ev: Event) {.importjs: "#.setPointerCapture(#.pointerId)".}
  proc keyAt(ev: Event): cstring {.importjs: "(#.target.closest('[data-key]')?.dataset.key ?? null)".}
  proc setStyle(e: Element, k, v: cstring) {.importjs: "#.style.setProperty(#, #)".}
  proc checked(e: Element): bool {.importjs: "#.checked".}
  proc clientXY(ev: Event): Vec {.importjs: "(e => ({x: e.clientX, y: e.clientY}))(#)".}
  proc setTimer(cb: proc (), ms: int): int {.importjs: "setTimeout(#, #)".}
  proc clearTimer(t: int) {.importjs: "clearTimeout(#)".}
  proc buzz() {.importjs: "(navigator.vibrate && navigator.vibrate(12))".}
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
    redirect: proc (s: S, key: string): string   # grabbing `key` may lift another item instead ("" = nothing)
    origin: Vec                   # where the held item was grabbed
    redirected: bool
    holdMs: int                   # how long a press on a redirected item waits before lifting the item itself
    targetAt: proc (p: Vec): bool # whether a landing spot gets the drop-target outline (nil: always)

  proc tr(p: Vec): cstring = cstring(&"translate({p.x:.2f}px, {p.y:.2f}px)")

  proc drawGhosts[S](st: Stage[S]) =
    var g = ""
    if st.dragKey.len > 0:
      if st.showGhosts:
        for l in st.picker.lands:
          if l.x == l.x: g.add &"""<circle class="land" cx="{l.x}" cy="{l.y}" r="6"/>"""
      if st.choice.ok and (st.targetAt.isNil or st.targetAt(st.choice.land)):
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

  proc start[S](st: Stage[S], grabbed: string, p: Vec, redirect = true) =
    var key = grabbed
    if redirect and not st.redirect.isNil: key = st.redirect(st.state, grabbed)
    if key.len == 0: return
    let behavior = st.spec(st.state, key)
    if behavior.isNil: return
    st.dragKey = key
    st.redirected = key != grabbed
    st.origin = st.render.locate(st.state, grabbed)
    st.grab = p - st.origin               # a redirected item starts where the grabbed one is
    st.picker = behavior(st.render, key)   # speculative renders happen here
    st.fg.appendChild(st.nodes[key])       # float above the others
    st.svg.classList.add("dragging")
    st.move(p)

  proc finish[S](st: Stage[S]) =
    if st.dragKey.len == 0: return
    let key = st.dragKey
    let was = st.render.locate(st.state, key)
    if st.choice.ok: st.state = st.choice.state
    let now = st.render.locate(st.state, key)
    st.dragKey = ""
    st.svg.classList.remove("dragging")
    let n = st.nodes[key]
    let snap = st.redirected and now.x == was.x and now.y == was.y
    if snap: n.setStyle("transition", "none")   # a copy let go nowhere melts back into the grabbed one: no glide
    st.draw(st.state)                      # the held tile glides home
    if snap:
      discard rectOf(n)
      n.setStyle("transition", "")
    if not st.onMove.isNil: st.onMove()
    if not st.onCommit.isNil: st.onCommit()

  proc setState[S](st: Stage[S], s: S) =
    st.state = s
    st.draw(s)
    if not st.onCommit.isNil: st.onCommit()

  proc mount[S](host: Element, w, h: float, init: S, render: Render[S],
                spec: proc (s: S, key: string): Behavior[S],
                backdrop, overlay: proc (s: S): string, x0 = 0.0): Stage[S] =
    host.innerHTML = cstring(&"""<svg class="d2" viewBox="{x0} 0 {w} {h}"><defs><filter id="rough"><feTurbulence type="fractalNoise" baseFrequency=".035" numOctaves="2" seed="7"/><feDisplacementMap in="SourceGraphic" scale="5"/></filter><filter id="cutout"><feTurbulence type="fractalNoise" baseFrequency=".012" numOctaves="1" seed="3"/><feDisplacementMap in="SourceGraphic" scale="9"/></filter></defs><g class="bg"></g>""" &
      """<g class="fg"></g><g class="overlay"></g><g class="ghosts"></g></svg>""" &
      """<label class="ghost-toggle"><input type="checkbox"> <span data-it="mostra il meccanismo">show machinery</span></label>""")
    let st = Stage[S](state: init, render: render, spec: spec, backdrop: backdrop, overlay: overlay, holdMs: 320)
    st.svg = host.querySelector("svg")
    st.bg = host.querySelector(".bg")
    st.fg = host.querySelector(".fg")
    st.top = host.querySelector(".overlay")
    st.ghosts = host.querySelector(".ghosts")
    let toLocal = proc (ev: Event): Vec =
      let (l, t, rw, rh) = rectOf(st.svg)
      let c = clientXY(ev)
      vec(x0 + (c.x - l) * w / rw, (c.y - t) * h / rh)
    # an item that a grab redirects (a letter on the board) waits a moment: moving at once pulls the redirected one
    # (a copy); holding still lifts the item itself, to move it
    var pendKey = ""
    var pendAt = vec(0, 0)
    var pendTimer = 0
    st.svg.addEventListener("pointerdown", proc (ev: Event) =
      let k = keyAt(ev)
      if k.isNil: return
      ev.preventDefault()
      capture(st.svg, ev)
      let p = toLocal(ev)
      var r = $k
      if not st.redirect.isNil: r = st.redirect(st.state, $k)
      if r.len == 0: return                # "": the page handles this grab itself
      if r == $k or st.spec(st.state, $k).isNil:
        st.start($k, p)
        return
      pendKey = $k
      pendAt = p
      pendTimer = setTimer(proc () =
        if pendKey.len > 0:
          let key = pendKey
          pendKey = ""
          buzz()
          st.start(key, pendAt, redirect = false), st.holdMs))
    st.svg.addEventListener("pointermove", proc (ev: Event) =
      let p = toLocal(ev)
      if pendKey.len > 0 and norm(p - pendAt) > 6:
        clearTimer(pendTimer)
        let key = pendKey
        pendKey = ""
        st.start(key, pendAt)
      if st.dragKey.len > 0: st.move(p))
    let up = proc (ev: Event) =
      if pendKey.len > 0:
        clearTimer(pendTimer)
        pendKey = ""
      st.finish()
    st.svg.addEventListener("pointerup", up)
    st.svg.addEventListener("pointercancel", up)
    let box = host.querySelector(".ghost-toggle input")
    box.addEventListener("change", proc (ev: Event) =
      st.showGhosts = box.checked
      st.drawGhosts())
    st.draw(init)
    st

  # ================================================================ builder wiring (new)
  import std/algorithm
  from solver as ps import nil       # src/solver.nim

  proc now(): float {.importjs: "Date.now()".}
  proc copyText(s: cstring) {.importjs: """(s => { const old = () => { const t = document.createElement('textarea'); t.value = s; document.body.appendChild(t); t.select(); try { document.execCommand('copy') } catch (e) {} t.remove() }; try { navigator.clipboard.writeText(s).catch(old) } catch (e) { old() } })(#)""".}
  proc setHidden(e: Element, h: bool) {.importjs: "#.hidden = #".}
  proc isHidden(e: Element): bool {.importjs: "#.hidden".}
  proc setDisabled(e: Element, d: bool) {.importjs: "#.disabled = #".}
  proc dataOf(ev: Event, k: cstring): cstring {.importjs: "((e, k) => e.target.closest('[data-' + k + ']')?.getAttribute('data-' + k) ?? null)(#, #)".}
  proc hoverIndex(ev: Event): cstring {.importjs: "(#.target.closest('[data-clue]')?.dataset.clue ?? null)".}
  proc value(e: Element): cstring {.importjs: "#.value".}
  proc setValue(e: Element, v: cstring) {.importjs: "#.value = #".}
  proc location(): cstring {.importjs: "(location.href)@".}
  proc queryParam(k: cstring): cstring {.importjs: "(new URLSearchParams(location.search).get(#) ?? '')".}
  proc setSkin(v: cstring) {.importjs: "document.body.dataset.skin = #".}
  setSkin("niki")

  # links point to the site the builder is served from (github.io or parloku.pietroppeter.xyz); anywhere else,
  # such as a preview, to the site's Pages address, which forwards to the custom domain
  proc onSite(): bool {.importjs: "(h => h.endsWith('github.io') || h.endsWith('pietroppeter.xyz'))(location.hostname)".}
  proc siteDir(): cstring {.importjs: "(location.origin + location.pathname.slice(0, location.pathname.lastIndexOf('/') + 1))".}
  let site = if onSite(): $siteDir() else: "https://pietroppeter.github.io/parloku/"
  let playUrl = site & "?p="
  proc templateText(id: cstring): cstring {.importjs: "(document.getElementById(#)?.innerHTML ?? '')".}
  var sets: seq[string]          # from data/terne.txt, minus the triples that already have a puzzle
  for line in ($templateText("terne")).split('|'):
    if line.len > 0: sets.add line
  if sets.len == 0: sets.add "NERO ROSA ORO"

  let host = document.getElementById("board")
  let cluesEl = document.getElementById("clues")
  let panelEl = document.getElementById("panel")
  let sayEl = document.getElementById("say")
  let undoBtn = document.getElementById("undo")
  var complete = true          # some full grid fits the letters on the board
  var count = 0                # solutions of the puzzle: word starts and pinned clues only
  var countDone = true

  var sayTimer = 0
  proc say(m: string) =
    ## messages float over the board for a moment, so they take no room
    sayEl.innerHTML = cstring(m)
    sayEl.setHidden(m.len == 0)
    if sayTimer != 0: clearTimer(sayTimer)
    if m.len > 0: sayTimer = setTimer(proc () =
      sayTimer = 0
      sayEl.setHidden(true), 3500)

  proc setPuzzle(words: seq[string]) =
    var ls = ""
    for w in words:
      for ch in w:
        if ch notin ls: ls.add ch
    var sorted = ls
    sorted.sort()
    puz = Puzzle(letters: sorted)
    for li in 0 .. 5: slotOf[li] = li
    for w in words: puz.clues.add Clue(pos: (row: 0, col: 0), word: w)
    wpath = newSeq[seq[int]](words.len)

  proc emptyBoard(): Board = puz.boardOf(puz.startGrid)

  proc toProblem(g: Grid, allTiles: bool): ps.Problem =
    ## the solver's problem: the word starts found, plus every tile (allTiles) or only the pinned clues
    for i in 0 .. 5: result.letters[i] = puz.letters[i]
    if allTiles:
      for c in 0 ..< 36:
        if g[c] != '.': result.letterHints.add ps.HintLetter(pos: (row: c div 6, col: c mod 6), letter: g[c])
    else:
      for gv in puz.givens: result.letterHints.add ps.HintLetter(pos: gv.pos, letter: gv.letter)
    for i, clue in puz.clues:
      if wpath[i].len > 0: result.wordHints.add ps.HintWord(pos: clue.pos, word: clue.word)

  proc orderedLetters(): string =
    ## the six letters in the order they sit below the board
    result = "      "
    for li in 0 .. 5: result[slotOf[li]] = puz.letters[li]
  proc playCode(): string =
    var p = Puzzle(letters: orderedLetters(), givens: puz.givens)
    for i, clue in puz.clues:
      if wpath[i].len > 0: p.clues.add clue
    p.encode

  # ---- the real solver: complete grids that keep every letter on the board and fit all three words,
  # trying every start for the words not on the board yet (up to 10 different grids)
  # The words are laid out cell by cell (a word never revisits a cell, two words never share one, and with
  # "niente U" no word turns back in a U); each layout's letters then go to the sudoku solver.
  type Fit = object
    grid: ps.Grid
    paths: seq[seq[int]]       # each word's cells
  var fitList: seq[Fit]        # up to 10 different grids
  var fitCut = false           # the search hit its budget before deciding
  var fitShown = 0             # the one drawn on the board
  var searchBudget = 500000
  const maxFits = 100          # solutions listed under the board
  var perLayout = 8            # grids tried per layout of the words, so the list mixes different layouts
  proc setPerLayout(n: int) {.exportc.} = perLayout = n
  proc setBudget(n: int) {.exportc.} = searchBudget = n
  var noUTurn = true           # for now: no word turns back on itself in a U (cells k and k+3 side by side)
  proc hasUTurn(path: seq[int]): bool =
    for k in 0 .. path.len - 4:
      let (a, b) = (path[k], path[k + 3])
      if abs(a div 6 - b div 6) + abs(a mod 6 - b mod 6) == 1: return true
  proc lettersProblem(g: array[36, char]): ps.Problem =
    for i in 0 .. 5: result.letters[i] = puz.letters[i]
    for c in 0 ..< 36:
      if g[c] != '.': result.letterHints.add ps.HintLetter(pos: (row: c div 6, col: c mod 6), letter: g[c])
  proc fits(g: array[36, char], c: int, ch: char): bool =
    if g[c] == ch: return true
    g[c] == '.' and peersOf[c].allIt(g[it] != ch)

  proc readings(at: proc (c: int): char, path: seq[int], word: string): int =
    ## how many ways (0, 1 or 2 = more) the word reads from the first cell of `path`, never using a cell twice
    var ways = 0
    var seen: array[36, bool]
    proc walk(c, k: int) =
      if ways > 1 or seen[c] or at(c) != word[k]: return
      if k == word.len - 1:
        inc ways
        return
      seen[c] = true
      let (r, col) = (c div 6, c mod 6)
      if r > 0: walk(c - 6, k + 1)
      if r < 5: walk(c + 6, k + 1)
      if col > 0: walk(c - 1, k + 1)
      if col < 5: walk(c + 1, k + 1)
      seen[c] = false
    walk(path[0], 0)
    ways
  proc unambiguous(sg: ps.Grid, path: seq[int]): bool =
    if path.len == 0: return true
    var word = ""
    for c in path: word.add sg[c div 6][c mod 6]
    readings(proc (c: int): char = sg[c div 6][c mod 6], path, word) == 1
  var sG: array[36, char]       # the search state, kept here: Nim closures cannot capture var parameters
  var sUsed: array[36, bool]
  var sPaths: seq[seq[int]]
  var sFound: seq[Fit]
  var sBudget = 0
  proc findFits(order: seq[int])
  proc step(order: seq[int], path: var seq[int], c: int) =
    # the next letter of word order[0] goes in cell c
    if sFound.len >= maxFits or sBudget <= 0: return
    dec sBudget
    let w = order[0]
    let word = puz.clues[w].word
    let k = path.len
    if sUsed[c] or not sG.fits(c, word[k]): return
    path.add c
    if noUTurn and path.len >= 4 and path[^4 .. ^1].hasUTurn:
      discard path.pop
      return
    let old = sG[c]
    sG[c] = word[k]
    sUsed[c] = true
    if path.len == word.len:
      # a whole word: go on only if the letters already there don't read it a second way,
      # and some sudoku still fits these letters
      dec sBudget
      var ok = true
      for v in 0 ..< sPaths.len:
        let p2 = if v == w: path else: sPaths[v]
        if p2.len > 0 and readings(proc (c: int): char = sG[c], p2, puz.clues[v].word) > 1: ok = false
      if ok and ps.solve(lettersProblem(sG), ps.defaultOptions(limit = 1, keep = 0)).count > 0:
        sPaths[w] = path
        findFits(order[1 .. ^1])
        sPaths[w] = @[]
    elif k + 1 < wpath[w].len:
      step(order, path, wpath[w][k + 1])   # the word's container on the board fixes its first cells
    else:
      let (r, col) = (c div 6, c mod 6)
      for (dr, dc) in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
        if r + dr in 0 .. 5 and col + dc in 0 .. 5: step(order, path, idx(r + dr, col + dc))
    sG[c] = old
    sUsed[c] = false
    discard path.pop
  proc findFits(order: seq[int]) =
    if sFound.len >= maxFits or sBudget <= 0: return
    if order.len == 0:
      dec sBudget
      let r = ps.solve(lettersProblem(sG), ps.defaultOptions(limit = min(maxFits - sFound.len, perLayout), keep = min(maxFits - sFound.len, perLayout)))
      for sg in r.solutions:
        if not sPaths.allIt(sg.unambiguous(it)): continue   # each word must read one way only
        if sFound.len < maxFits and not sFound.anyIt(it.grid == sg): sFound.add Fit(grid: sg, paths: sPaths)
      return
    let w = order[0]
    var path: seq[int]
    if wpath[w].len > 0: step(order, path, wpath[w][0])
    else:
      for c in 0 ..< 36: step(order, path, c)

  proc showFit() =
    for c in 0 ..< 36: solGrid[c] = '.'
    solPaths = @[]
    if fitShown < fitList.len:
      let f = fitList[fitShown]
      for c in 0 ..< 36: solGrid[c] = f.grid[c div 6][c mod 6]
      solPaths = f.paths
    for c in 0 ..< 36: solWord[c] = -1
    for i, path in solPaths:
      for c in path: solWord[c] = i

  proc analyze(b: Board) =
    let g = b.grid
    # pinned clues follow their tiles: a pin whose cell was emptied or changed goes away
    var keep: seq[Given]
    for gv in puz.givens:
      if g[idx(gv.pos)] == gv.letter: keep.add gv
    puz.givens = keep
    # a word keeps its cells while they spell it: it loses a letter that was taken away, and the ones after it
    for i in 0 ..< wpath.len:
      var k = 0
      while k < wpath[i].len and g[wpath[i][k]] == puz.clues[i].word[k]: inc k
      wpath[i].setLen(k)
      if k > 0: puz.clues[i].pos = (row: wpath[i][0] div 6, col: wpath[i][0] mod 6)
    # pencil marks: exact when some full grid fits, else plain sudoku elimination
    let p = toProblem(g, allTiles = true)
    complete = g.clashes.len == 0 and ps.solve(p, ps.defaultOptions(limit = 1, keep = 0)).count > 0
    if complete:
      let cands = ps.candidates(p)
      for c in 0 ..< 36:
        marks[c] = ""
        for ch in cands[c div 6][c mod 6]: marks[c].add ch
    else:
      for c in 0 ..< 36:
        marks[c] = ""
        for ch in puz.letters:
          if peersOf[c].allIt(g[it] != ch): marks[c].add ch
    for c in 0 ..< 36: noneCell[c] = g[c] == '.' and marks[c].len == 0
    # words on the board first, then the longest
    var order: seq[int]
    for i in 0 ..< puz.clues.len: order.add i
    order.sort(proc (a, b: int): int =
      result = cmp(wpath[b].len > 0, wpath[a].len > 0)
      if result == 0: result = cmp(puz.clues[b].word.len, puz.clues[a].word.len))
    for c in 0 ..< 36:
      sG[c] = g[c]
      sUsed[c] = false
    sPaths = newSeq[seq[int]](puz.clues.len)
    sFound = @[]
    sBudget = searchBudget
    if g.clashes.len == 0: findFits(order)
    fitList = sFound
    fitCut = sBudget <= 0 and sFound.len < maxFits
    fitShown = 0
    showFit()
    let r = ps.solve(toProblem(g, allTiles = false), ps.defaultOptions(limit = 1000, keep = 0))
    count = r.count
    countDone = r.complete

  proc showClues(b: Board) =
    var html = ""
    for i, clue in puz.clues:
      let path = wpath[i]
      let full = path.len == clue.word.len
      let cls = if full: " done" else: ""
      let on = if path.len > 0: " on" else: ""
      html.add &"""<div class="clue{cls}" data-clue="{i}" style="border-color:var(--w{i mod 3})">"""
      for k, ch in clue.word:
        let li = puz.letters.find(ch)
        if k < path.len:
          html.add &"""<span class="l on" style="background:var(--g{li});color:var(--i{li})">{ch}</span>"""
        else:
          html.add &"""<span class="l">{ch}</span>"""
      let tick = if full: "✓" else: ""
      html.add &"""<span class="ok">{tick}</span>"""
      # the ring sits at the right end, where the thumb reaches it; its catch area is wider than it looks
      html.add &"""<span class="wring{on}" data-ring="{i}" style="--wc:var(--w{i mod 3})"></span></div>"""
    cluesEl.innerHTML = cstring(html)

  let solsEl = document.getElementById("sols")
  proc showFits() =
    ## one numbered circle per solution found (up to 100), in two rows that scroll sideways; the one shown is filled
    var s = ""
    if fitList.len == 0:
      if fitCut: s = """<span class="none">…</span>"""
      else: s = """<span class="none zero">0 soluzioni: così le parole non ci stanno</span>"""
    for k in 0 ..< fitList.len:
      var on = ""
      if k == fitShown: on = " on"
      s.add &"""<button class="sc{on}" data-k="{k}">{k + 1}</button>"""
    if fitCut and fitList.len > 0: s.add """<span class="sc more" title="la ricerca si è fermata: potrebbero essercene altre">…</span>"""
    solsEl.innerHTML = cstring(s)
  proc dataK(ev: Event): cstring {.importjs: "(#.target.closest('[data-k]')?.dataset.k ?? null)".}

  proc showPanel(b: Board) =
    var s = ""
    var found, full = 0
    for i, clue in puz.clues:
      if wpath[i].len > 0:
        inc found
        if wpath[i].len == clue.word.len: inc full
    if found == 0:
      s.add """<span class="verdict">per chi gioca: trascina una parola sulla griglia</span>"""
    else:
      let n = if countDone: $count else: "≥ " & $count
      let cls = if count == 1: "one" elif count == 0: "zero" else: "many"
      let what = if count == 1: "soluzione per chi gioca: pronto!" else: "soluzioni per chi gioca"
      s.add &"""<span class="verdict {cls}"><b>{n}</b> {what}</span>"""
      s.add &"""<span class="note">{full}/{puz.clues.len} parole · {puz.givens.len} indizi</span>"""
      s.add &"""<a class="btn sm" href="{playUrl}{playCode()}" target="_blank" rel="noopener">▶ gioca</a>"""
    if not complete:
      s.add """<span class="warn">nessuna griglia completa: c'è una casella senza possibilità o un conflitto</span>"""
    panelEl.innerHTML = cstring(s)

  proc freeTile(b: Board, ch: char): int =
    let li = puz.letters.find(ch)
    for k in 0 .. 5:
      if b.cells.find(li * 6 + k) < 0: return li * 6 + k
    -1
  proc canPut(b: Board, c: int, ch: char): bool =
    ## a word's letter can go in cell c: it is there already, or the cell is empty and the letter clashes with nothing;
    ## for now no word runs through a cell twice, and no two words share one
    if wpath.anyIt(c in it): return false
    let g = b.grid
    if g[c] == ch: return true
    g[c] == '.' and peersOf[c].allIt(g[it] != ch) and b.freeTile(ch) >= 0
  proc putAt(b: var Board, c: int, ch: char) =
    if b.cells[c] < 0: b.cells[c] = b.freeTile(ch)
  proc cutAt(b: Board, c: int): Board =
    ## the letter in cell c goes back below; a word running through it loses it and every letter after it
    ## (a cell another word still uses, or a pinned one, keeps its letter)
    result = b
    var freed = @[c]
    for i in 0 ..< wpath.len:
      let k = wpath[i].find(c)
      if k >= 0:
        for cc in wpath[i][k .. ^1]: freed.add cc
        wpath[i].setLen(k)
    for cc in freed:
      if cc == c or (not wpath.anyIt(cc in it) and not isGiven(cc)): result.cells[cc] = -1
  proc growOptions(b: Board, w: int): seq[int] =
    ## the cells next to a word's last letter where its next letter can go
    let path = wpath[w]
    let word = puz.clues[w].word
    if path.len == 0 or path.len >= word.len: return
    let c = path[^1]
    let (r, col) = (c div 6, c mod 6)
    for (dr, dc) in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
      let (rr, cc) = (r + dr, col + dc)
      if rr in 0 .. 5 and cc in 0 .. 5 and b.canPut(idx(rr, cc), word[path.len]):
        if noUTurn and (path & @[idx(rr, cc)]).hasUTurn: continue
        result.add idx(rr, cc)

  setPuzzle(sets[0].split(' '))
  let stage = mount(host, 500, 664, emptyBoard(), renderBoard, tileSpec, backdrop, overlay, 50)
  stage.targetAt = proc (p: Vec): bool = p.y < by + 6 * cell   # as in the player: only cells are drop targets
  host.querySelector(".ghost-toggle").setHidden(true)
  # letters on the board stay put: grabbing one pulls out a copy of it (holding still lifts it, a double tap sends it back)
  stage.redirect = proc (b: Board, key: string): string =
    let id = parseInt(key[1 .. ^1])
    if b.cells.find(id) < 0: return key
    for k in 0 .. 5:
      if b.cells.find((id div 6) * 6 + k) < 0: return &"t{(id div 6) * 6 + k}"
    ""

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
      let home = stage.origin              # the letter it was pulled from: below, or on the board
      let dd = norm(stage.at - home)
      let atHome = stage.choice.ok and stage.choice.state.cells.find(id) < 0
      var others = false                 # copies left under the held one: then it divides, else it moves whole
      for k in 0 .. 5:
        if li * 6 + k != id and stage.state.cells.find(li * 6 + k) < 0: others = true
      if stage.redirected: others = true   # the board letter it came from stays
      if fromCell < 0 and others and atHome:
        pulling = true
        d = neckPath(home, stage.at, 31, waist(dd, 31))
      elif fromCell >= 0 and atHome and dd < 2.6 * cell:
        d = neckPath(stage.at, home, 31, waist(dd, 31))
      if joined and not pulling and fromCell < 0 and others: ripple(home, li)
    joined = pulling
    if d.len > 0: necks.innerHTML = cstring(&"""<path class="neck g{li}" d="{d}"/>""")
    else: necks.innerHTML = ""
  # ---- a double tap on a tile on the board sends it back to its letter below
  var tapKey = ""
  var tapAt = 0.0
  var downAt = vec(0, 0)
  var downKey: cstring = nil              # the tile under the finger when it went down (pointerup lands on the svg: it is captured)
  stage.svg.addEventListener("pointerdown", proc (ev: Event) =
    downKey = keyAt(ev)
    downAt = clientXY(ev))
  stage.svg.addEventListener("pointerup", proc (ev: Event) =
    let k = downKey
    let up = clientXY(ev)
    if k.isNil or norm(up - downAt) > 8:   # a drag, not a tap
      tapKey = ""
      return
    let id = parseInt(($k)[1 .. ^1])
    let at = stage.state.cells.find(id)
    if at < 0 or isGiven(at): return
    let t = now()
    if tapKey == $k and t - tapAt < 400:
      tapKey = ""
      stage.setState(stage.state.cutAt(at))
    else:
      tapKey = $k
      tapAt = t)

  proc attr(e: Element, k: cstring): cstring {.importjs: "#.getAttribute(#)".}
  proc setAttr(e: Element, k, v: cstring) {.importjs: "#.setAttribute(#, #)".}
  # ---- letters in conflict tremble like restless marbles: they roll a little left and right (turning as they go),
  # gently at first and more for 3 seconds. An SVG transform set every frame, so it is the same in every browser
  proc nextFrame(cb: proc (t: float)) {.importjs: "requestAnimationFrame(#)".}
  proc shaking(): seq[Element] {.importjs: "Array.from(document.querySelectorAll('.shake'))".}
  proc lessMotion(): bool {.importjs: "matchMedia('(prefers-reduced-motion: reduce)').matches".}
  proc isHeld(e: Element): bool {.importjs: "!!#.closest('.dragging')".}
  proc unset(e: Element, k: cstring) {.importjs: "#.removeAttribute(#)".}
  const rollMax = 4.0                  # board units side to side at most (a tile's radius is 32)
  const rollRamp = 3000.0              # ms to grow from a fifth to all of it
  proc roll(t: float) =
    for g in shaking():
      if g.attr("data-t0").isNil: g.setAttr("data-t0", cstring($t))
      if lessMotion() or g.isHeld:
        g.unset("transform")
        g.setAttr("data-t0", cstring($t))
        continue
      let k = min(1.0, 0.2 + 0.8 * (t - parseFloat($g.attr("data-t0"))) / rollRamp)
      let dx = rollMax * k * sin(t / 1000 * 2 * PI * 2.2)
      let turn = dx / 32 * 180 / PI       # rolling, not sliding: the turn matches the distance
      g.setAttr("transform", cstring(&"translate({dx:.2f} 0) rotate({turn:.2f})"))
    nextFrame(roll)
  nextFrame(roll)

  # ---- 📌: drag the pin onto a letter on the board to make it a clue; hold a pinned letter to unpin it
  proc buzz2() {.importjs: "(navigator.vibrate && navigator.vibrate(12))".}
  proc setPos(e: Element, x, y: float) {.importjs: "((e, x, y) => { e.style.transform = 'translate(' + x + 'px,' + y + 'px)' })(#, #, #)".}
  proc capture2(e: Element, ev: Event) {.importjs: "#.setPointerCapture(#.pointerId)".}
  proc cellUnder(ev: Event): int =
    ## the board cell under the pointer, -1 outside the grid (the stage's viewBox starts at x = 50, 500 × 664)
    let (l, t, rw, rh) = rectOf(stage.svg)
    let c = clientXY(ev)
    let x = 50 + (c.x - l) * 500 / rw
    let y = (c.y - t) * 664 / rh
    let col = int(floor((x - bx) / cell))
    let row = int(floor((y - by) / cell))
    if row in 0 .. 5 and col in 0 .. 5: idx(row, col) else: -1
  proc pinAt(c: int): bool =
    for gv in puz.givens:
      if idx(gv.pos) == c: return true
  let pinSrc = document.getElementById("pinsrc")
  let ghost = document.createElement("div")
  ghost.className = "pinghost"
  ghost.innerHTML = "📌"
  ghost.setHidden(true)
  document.body.appendChild(ghost)
  var carrying = false
  pinSrc.addEventListener("pointerdown", proc (ev: Event) =
    ev.preventDefault()
    carrying = true
    capture2(pinSrc, ev)
    let c = clientXY(ev)
    ghost.setHidden(false)
    ghost.setPos(c.x - 18, c.y - 30))
  pinSrc.addEventListener("pointermove", proc (ev: Event) =
    if not carrying: return
    let c = clientXY(ev)
    ghost.setPos(c.x - 18, c.y - 30))
  proc dropPin(ev: Event) =
    if not carrying: return
    carrying = false
    ghost.setHidden(true)
    let c = cellUnder(ev)
    if c < 0: return
    let id = stage.state.cells[c]
    if id < 0:
      say "La puntina va su una lettera già sulla griglia."
      return
    if not pinAt(c):
      puz.givens.add Given(pos: (row: c div 6, col: c mod 6), letter: letterOf(id))
      buzz2()
      stage.setState(stage.state)
  pinSrc.addEventListener("pointerup", dropPin)
  pinSrc.addEventListener("pointercancel", proc (ev: Event) =
    carrying = false
    ghost.setHidden(true))
  # holding a pinned letter still for a moment takes its pin off
  var holdTimer = 0
  var holdAt = vec(0, 0)
  stage.svg.addEventListener("pointerdown", proc (ev: Event) =
    let c = cellUnder(ev)
    if c < 0 or not pinAt(c): return
    holdAt = clientXY(ev)
    holdTimer = setTimer(proc () =
      holdTimer = 0
      var keep: seq[Given]
      for gv in puz.givens:
        if idx(gv.pos) != c: keep.add gv
      puz.givens = keep
      buzz2()
      stage.setState(stage.state), 450))
  stage.svg.addEventListener("pointermove", proc (ev: Event) =
    if holdTimer != 0 and norm(clientXY(ev) - holdAt) > 8:
      clearTimer(holdTimer)
      holdTimer = 0)
  stage.svg.addEventListener("pointerup", proc (ev: Event) =
    if holdTimer != 0:
      clearTimer(holdTimer)
      holdTimer = 0)

  # ---- words are containers: drag a word's ring onto the board, then hold its last letter to lengthen it
  proc localOf(ev: Event): Vec =
    let (l, t, rw, rh) = rectOf(stage.svg)
    let c = clientXY(ev)
    vec(50 + (c.x - l) * 500 / rw, (c.y - t) * 664 / rh)
  proc stopIt(ev: Event) {.importjs: "#.stopPropagation()".}
  proc redrawTop() = stage.top.innerHTML = cstring(overlay(stage.state))

  let ringGhost = document.createElement("div")
  ringGhost.className = "ringghost"
  ringGhost.setHidden(true)
  document.body.appendChild(ringGhost)
  proc setWc(e: Element, i: int) {.importjs: "#.style.setProperty('--wc', 'var(--w' + # + ')')".}
  var ringWord = -1
  var ringDown = vec(0, 0)
  var ringMoved = false
  var ringTapWord = -1
  var ringTapAt = 0.0
  cluesEl.addEventListener("pointerdown", proc (ev: Event) =
    let r = dataOf(ev, "clue")            # the whole word row grabs its ring
    if r.isNil: return
    ev.preventDefault()
    ringWord = parseInt($r)
    ringDown = clientXY(ev)
    ringMoved = false
    capture2(cluesEl, ev))
  cluesEl.addEventListener("pointermove", proc (ev: Event) =
    if ringWord < 0: return
    let c = clientXY(ev)
    if not ringMoved and norm(c - ringDown) > 6:
      ringMoved = true
      ringGhost.setWc(ringWord mod 3)
      ringGhost.setHidden(false)
    if ringMoved: ringGhost.setPos(c.x - 24, c.y - 24))
  cluesEl.addEventListener("pointerup", proc (ev: Event) =
    if ringWord < 0: return
    let w = ringWord
    ringWord = -1
    ringGhost.setHidden(true)
    if not ringMoved:
      # a double tap on a placed word's ring takes the word off the board
      let t = now()
      if ringTapWord == w and t - ringTapAt < 400 and wpath[w].len > 0:
        ringTapWord = -1
        stage.setState(stage.state.cutAt(wpath[w][0]))
      else:
        ringTapWord = w
        ringTapAt = t
      return
    let c = cellUnder(ev)
    if c < 0: return
    var b = stage.state
    if wpath[w].len > 0: b = b.cutAt(wpath[w][0])     # a word already on the board moves to its new start
    let ch = puz.clues[w].word[0]
    if not b.canPut(c, ch):
      say &"«{ch}» non può andare lì: c'è già un'altra lettera o la stessa lettera nella riga, colonna o riquadro."
      return
    b.putAt(c, ch)
    wpath[w] = @[c]
    buzz2()
    say ""
    stage.setState(b))
  cluesEl.addEventListener("pointercancel", proc (ev: Event) =
    ringWord = -1
    ringGhost.setHidden(true))

  # holding the last letter of a word shows where the next one can go; drag there (or tap one) to add it
  var growing = -1                # pointer down on a word's last letter
  var growDown = vec(0, 0)
  var growMoved = false
  var growTimer = 0
  var tailTapCell = -1
  var tailTapAt = 0.0
  var stepped = false             # this drag already grew or shrank the word
  proc showOpts(w: int) =
    growWord = w
    growOpts = stage.state.growOptions(w)
    buzz2()
    redrawTop()
  proc clearOpts() =
    growWord = -1
    growOpts = @[]
    stage.ghosts.innerHTML = ""
    redrawTop()
  proc grow(w, c: int) =
    var b = stage.state
    b.putAt(c, puz.clues[w].word[wpath[w].len])
    wpath[w].add c
    growWord = -1
    growOpts = @[]
    stage.ghosts.innerHTML = ""
    buzz2()
    stage.setState(b)
  proc nearestOpt(p: Vec): int =
    result = -1
    var best = cell * 0.8
    for c in growOpts:
      let d = norm(cellPos(c) - p)
      if d < best:
        best = d
        result = c
  host.addEventListener("pointerdown", proc (ev: Event) =
    let c = cellUnder(ev)
    if growWord >= 0 and growing < 0:
      # options showing from a hold: a tap on one adds the letter, anything else puts them away
      let w = growWord
      if c in growOpts:
        stopIt(ev)
        ev.preventDefault()
        grow(w, c)
        return
      clearOpts()
    if c < 0: return
    # the head of a word: the last cell of its container (an unfinished word wins)
    var w = -1
    for i in 0 ..< wpath.len:
      if wpath[i].len > 0 and wpath[i][^1] == c:
        if w < 0 or wpath[i].len < puz.clues[i].word.len: w = i
    if w < 0: return
    stopIt(ev)
    ev.preventDefault()
    capture2(host, ev)
    growing = w
    growDown = clientXY(ev)
    growMoved = false
    stepped = false
    growTimer = setTimer(proc () =
      growTimer = 0
      if growing >= 0: showOpts(growing), 260), true)
  host.addEventListener("pointermove", proc (ev: Event) =
    if growing < 0: return
    if not growMoved and norm(clientXY(ev) - growDown) > 6:
      growMoved = true
      if growWord != growing: showOpts(growing)
    if not growMoved: return
    # the snake follows the finger: near the centre of a free next cell it grows there,
    # back onto the letter before the head it shrinks; this repeats within one drag
    let p = localOf(ev)
    let wi = growing
    let path = wpath[wi]
    let word = puz.clues[wi].word
    if path.len < word.len:
      for c in stage.state.growOptions(wi):
        if norm(p - cellPos(c)) < cell * 0.42:
          var b = stage.state
          b.putAt(c, word[path.len])
          wpath[wi].add c
          stepped = true
          buzz2()
          stage.setState(b)
          if wpath[wi].len < word.len: showOpts(wi) else: clearOpts()
          return
    if path.len >= 2 and norm(p - cellPos(path[^2])) < cell * 0.42:
      stepped = true
      buzz2()
      stage.setState(stage.state.cutAt(path[^1]))
      showOpts(wi)
      return
    if stepped:
      stage.ghosts.innerHTML = ""
      return
    # no step yet: the head letter follows the finger (let go on an empty cell to move it there)
    let ch = word[path.len - 1]
    let li = puz.letters.find(ch)
    stage.ghosts.innerHTML = cstring(&"""<g class="growtile" transform="translate({p.x:.1f},{p.y:.1f})"><circle r="31" style="fill:var(--g{li})"/>""" &
      &"""<text y="12" text-anchor="middle" font-size="34" class="glyph i{li}">{ch}</text></g>"""))
  proc growUp(ev: Event) =
    if growing < 0: return
    let w = growing
    growing = -1
    if growTimer != 0:
      clearTimer(growTimer)
      growTimer = 0
    if not growMoved:
      if growWord == w: return               # held still: the options stay, tap one
      # a quick tap: two of them take the letter (and the ones after it) off
      let c = wpath[w][^1]
      let t = now()
      if tailTapCell == c and t - tailTapAt < 400:
        tailTapCell = -1
        if not isGiven(c): stage.setState(stage.state.cutAt(c))
      else:
        tailTapCell = c
        tailTapAt = t
      return
    clearOpts()
    if stepped: return
    # a drag that took no step: the head moves to the empty cell it was let go on
    let c = cellUnder(ev)
    let path = wpath[w]
    if c < 0 or c == path[^1] or stage.state.cells[c] >= 0 or isGiven(path[^1]): return
    let ch = puz.clues[w].word[path.len - 1]
    var b = stage.state.cutAt(path[^1])
    if path.len == 1:
      if not b.canPut(c, ch): return
      wpath[w] = @[c]               # a one-letter word moves its start
    b.putAt(c, ch)
    stage.setState(b)
  host.addEventListener("pointerup", growUp)
  # a double tap on an empty cell whose pencil marks leave one letter puts that letter there;
  # if it is the next letter of a word ending next to it, the word takes it
  var emptyTapCell = -1
  var emptyTapAt = 0.0
  var emptyDown = -1
  var emptyDownAt = vec(0, 0)
  host.addEventListener("pointerdown", proc (ev: Event) =
    let c = cellUnder(ev)
    emptyDown = if c >= 0 and stage.state.cells[c] < 0: c else: -1
    emptyDownAt = clientXY(ev))
  host.addEventListener("pointerup", proc (ev: Event) =
    let c = emptyDown
    emptyDown = -1
    if c < 0 or stage.dragKey.len > 0 or norm(clientXY(ev) - emptyDownAt) > 8: return
    if stage.state.cells[c] >= 0: return
    let t = now()
    if emptyTapCell != c or t - emptyTapAt > 400:
      emptyTapCell = c
      emptyTapAt = t
      return
    emptyTapCell = -1
    if marks[c].len != 1:
      say &"Qui ci sono ancora {marks[c].len} possibilità."
      return
    let ch = marks[c][0]
    var b = stage.state
    if b.freeTile(ch) < 0: return
    b.putAt(c, ch)
    for i in 0 ..< wpath.len:
      let p = wpath[i]
      let word = puz.clues[i].word
      if p.len > 0 and p.len < word.len and word[p.len] == ch:
        let (r1, c1, r2, c2) = (p[^1] div 6, p[^1] mod 6, c div 6, c mod 6)
        if abs(r1 - r2) + abs(c1 - c2) == 1:
          wpath[i].add c
          break
    buzz2()
    stage.setState(b))

  host.addEventListener("pointercancel", proc (ev: Event) =
    growing = -1
    clearOpts())

  # ---- after every change: find the words, redo the pencil marks and the count
  var history: seq[(Board, seq[Given], seq[seq[int]])]
  var last = stage.state
  var lastGivens: seq[Given]
  var lastPaths = wpath
  proc refresh() =
    analyze(stage.state)
    stage.draw(stage.state)
    showClues(stage.state)
    showFits()
  stage.onCommit = proc () =
    if stage.state.cells != last.cells or puz.givens != lastGivens or wpath != lastPaths:
      history.add (last, lastGivens, lastPaths)
      last = stage.state
    refresh()
    lastGivens = puz.givens
    lastPaths = wpath
    undoBtn.setDisabled(history.len == 0)
  undoBtn.addEventListener("click", proc (ev: Event) =
    if history.len == 0: return
    let (b, gv, wp) = history.pop
    puz.givens = gv
    lastGivens = gv
    wpath = wp
    lastPaths = wp
    last = b
    stage.state = b
    refresh()
    undoBtn.setDisabled(history.len == 0))
  document.getElementById("reset").addEventListener("click", proc (ev: Event) =
    puz.givens = @[]
    for p in wpath.mitems: p.setLen(0)
    stage.setState(emptyBoard()))

  # ---- hold a letter below: the six letters wiggle and can be reordered (drag one onto another to swap them)
  proc addClass(e: Element, c: cstring) {.importjs: "#.classList.add(#)".}
  proc dropClass(e: Element, c: cstring) {.importjs: "#.classList.remove(#)".}
  proc inHost(ev: Event): bool {.importjs: "(e => e.target instanceof Node && document.getElementById('board').contains(e.target))(#)".}
  let jigStyle = document.createElement("style")
  document.head.appendChild(jigStyle)
  var jiggling = false
  var jigHeld = -1                 # the letter being moved while wiggling
  var jigDown = vec(0, 0)
  var jigMoved = false
  var pressTimer = 0
  var pressAt = vec(0, 0)
  var pressStarted = false         # this press started the wiggling: its release is not a tap
  proc stackUnder(p: Vec): int =
    result = -1
    for li in 0 .. 5:
      if norm(stackPos(li) - p) < 36: return li
  proc tileLook(li: int): string =
    for it in renderBoard(stage.state):
      let id = parseInt(it.key[1 .. ^1])
      if id div 6 == li and stage.state.cells.find(id) < 0: return it.svg
    tileSvg(li, false)
  # while wiggling the six letters are drawn on top (the real stacks hidden). Dragging one works like the
  # NIMBUS word of the declarative dragging explainer: the others make room live, by list insertion
  let jigG = svgNode("g")
  jigG.setAttribute("class", "jigs")
  stage.svg.appendChild(jigG)
  var jigN: seq[Element]
  for li in 0 .. 5:
    let n = svgNode("g")
    jigG.appendChild(n)
    jigN.add n
  proc orderNow(): seq[int] =
    result = newSeq[int](6)
    for li in 0 .. 5: result[slotOf[li]] = li
  proc moveTo(xs: seq[int], x, i: int): seq[int] =
    result = xs
    result.delete(xs.find(x))
    result.insert(x, i)
  proc nearestSlot(p: Vec): int =
    var best = 1e9
    for i in 0 .. 5:
      let d = norm(slotPos(i) - p)
      if d < best:
        best = d
        result = i
  var jigPlan: seq[int]            # the order the held letter would make if let go now
  proc drawJig(at = vec(0, 0)) =
    jigPlan = orderNow()
    if jigHeld >= 0: jigPlan = jigPlan.moveTo(jigHeld, nearestSlot(at))
    for i, li in jigPlan:
      let n = jigN[li]
      if n.innerHTML.len == 0 or not jiggling:
        n.innerHTML = cstring(&"""<g class="jig j{li mod 2}">{tileLook(li)}</g>""")
      let held = li == jigHeld
      n.setStyle("transition", if held: "none" else: "transform .2s ease")
      n.setStyle("transform", tr(if held: at else: slotPos(i)))
      n.setAttribute("class", if held: "jt lift" else: "jt")
    if jigHeld >= 0: jigG.appendChild(jigN[jigHeld])     # the held one floats above
  proc startJiggle() =
    jiggling = true
    # the tile the press lifted goes back: the stacks are drawn wiggling on top, the real ones hidden
    if stage.dragKey.len > 0:
      stage.dragKey = ""
      stage.svg.dropClass("dragging")
      stage.draw(stage.state)
      if not stage.onMove.isNil: stage.onMove()
    var css = ""
    for id in 0 ..< 36:
      if stage.state.cells.find(id) < 0:
        if css.len > 0: css.add ","
        css.add &"""#board [data-key="t{id}"]"""
    if css.len > 0: css.add "{visibility:hidden}"
    jigStyle.innerHTML = cstring(css)
    stage.svg.addClass("jiggling")
    for n in jigN: n.innerHTML = ""
    jigG.setHidden(false)
    buzz2()
    say "Trascina una lettera dove vuoi: le altre si spostano. Doppio tocco su una lettera per finire."
    drawJig()
  proc stopJiggle() =
    jiggling = false
    jigHeld = -1
    jigStyle.innerHTML = ""
    stage.svg.dropClass("jiggling")
    jigG.setHidden(true)
    say ""
  jigG.setHidden(true)
  proc commitOrder(order: seq[int]) =
    ## only the letters below move: the board, its colours and the words stay as they are
    for i, li in order: slotOf[li] = i
    stage.draw(stage.state)
    refresh()
  # holding a letter below starts the wiggling, a double tap on a letter ends it
  var stackTap = -1
  var stackTapAt = 0.0
  var downStack = -1
  proc doubleTap(li: int): bool =
    let t = now()
    if li >= 0 and stackTap == li and t - stackTapAt < 400:
      stackTap = -1
      return true
    stackTap = li
    stackTapAt = t
  document.addEventListener("pointerdown", proc (ev: Event) =
    downStack = -1
    if not inHost(ev): return
    let li = stackUnder(localOf(ev))
    pressAt = clientXY(ev)
    downStack = li
    if not jiggling:
      if li >= 0:
        pressTimer = setTimer(proc () =
          pressTimer = 0
          pressStarted = true
          startJiggle(), 450)
      return
    stopIt(ev)
    ev.preventDefault()
    capture2(host, ev)
    jigHeld = li
    jigDown = clientXY(ev)
    jigMoved = false, true)
  document.addEventListener("pointermove", proc (ev: Event) =
    if pressTimer != 0 and norm(clientXY(ev) - pressAt) > 8:
      clearTimer(pressTimer)
      pressTimer = 0
    if not jiggling or jigHeld < 0: return
    if norm(clientXY(ev) - jigDown) > 6: jigMoved = true
    if jigMoved: drawJig(localOf(ev)), true)
  document.addEventListener("pointerup", proc (ev: Event) =
    let li = downStack
    downStack = -1
    if pressTimer != 0:
      clearTimer(pressTimer)
      pressTimer = 0
    if not jiggling: return
    stopIt(ev)
    if pressStarted:               # the release of the press that started the wiggling
      pressStarted = false
      jigHeld = -1
      drawJig()
      return
    let held = jigHeld
    if not jigMoved:
      jigHeld = -1
      if doubleTap(li): stopJiggle()
      else: drawJig()
      return
    stackTap = -1
    if held >= 0:
      drawJig(localOf(ev))
      let plan = jigPlan
      jigHeld = -1
      if plan != orderNow():
        buzz2()
        commitOrder(plan)
    drawJig(), true)

  document.addEventListener("pointercancel", proc (ev: Event) =
    pressStarted = false
    if jiggling:
      jigHeld = -1
      drawJig(), true)
  # no text selection, callout or context menu on the game: presses are for the tiles
  proc noMenus(e: Element) {.importjs: """((e) => { e.addEventListener('contextmenu', ev => ev.preventDefault()); e.addEventListener('selectstart', ev => { if (!(ev.target instanceof HTMLInputElement)) ev.preventDefault() }) })(#)""".}
  proc noTouchDefaults(e: Element) {.importjs: """((e) => e.addEventListener('touchstart', ev => { if (ev.cancelable) ev.preventDefault() }, { passive: false }))(#)""".}
  noMenus(document.getElementById("bld"))
  noTouchDefaults(host)
  noTouchDefaults(cluesEl)

  # ---- tap a word: its outline on the board wiggles
  cluesEl.addEventListener("click", proc (ev: Event) =
    let i = hoverIndex(ev)
    if i.isNil: return
    wiggleClue = parseInt($i)
    stage.top.innerHTML = cstring(overlay(stage.state))
    discard setTimer(proc () =
      wiggleClue = -1
      if stage.dragKey.len == 0: stage.top.innerHTML = cstring(overlay(stage.state)), 700))

  panelEl.addEventListener("click", proc (ev: Event) =
    let t = ev.target
    if not t.isNil and $t.id == "copy":
      copyText(cstring(playUrl & playCode()))
      t.innerHTML = "✓ copiato")

  # ---- word sets
  proc loadSet(text: string): bool =
    let ws = text.toUpperAscii.splitWhitespace
    if ws.len == 0: return
    var ls = ""
    for w in ws:
      for ch in w:
        if ch notin {'A'..'Z'}:
          say &"«{w}»: solo lettere A-Z."
          return
        if ch notin ls: ls.add ch
    if ls.len != 6:
      say &"Queste parole usano {ls.len} lettere diverse: ne servono esattamente 6."
      return
    for w in ws:
      for i in 1 ..< w.len:
        if w[i] == w[i - 1]:
          say &"«{w}» ha una doppia: due lettere uguali non possono stare in caselle vicine."
          return
    setPuzzle(ws)
    history = @[]
    lastGivens = @[]
    lastPaths = wpath
    last = emptyBoard()
    undoBtn.setDisabled(true)
    stage.setState(emptyBoard())
    true

  var setsHtml = ""
  for i, st in sets:
    setsHtml.add &"""<button class="btn" data-set="{i}">{st.replace(" ", " · ")}</button>"""
  document.getElementById("sets").innerHTML = cstring(setsHtml)
  document.getElementById("sets").addEventListener("click", proc (ev: Event) =
    let i = dataOf(ev, "set")
    if not i.isNil:
      document.getElementById("custom").setValue(cstring(sets[parseInt($i)]))
      discard loadSet(sets[parseInt($i)]))
  document.getElementById("edit").addEventListener("click", proc (ev: Event) =
    let row = document.getElementById("customrow")
    row.setHidden(not row.isHidden))
  document.getElementById("use").addEventListener("click", proc (ev: Event) =
    discard loadSet($document.getElementById("custom").value))

  # ---- 💾 the builder's whole state in a link: letters (in their order) ~ words ~ each word's cells ~ board ~ pins
  const b36 = "0123456789abcdefghijklmnopqrstuvwxyz"
  proc stateCode(): string =
    var paths, board, pins: string
    for i, p in wpath:
      if i > 0: paths.add '-'
      for c in p: paths.add b36[c]
    let g = stage.state.grid
    for c in 0 ..< 36: board.add (if g[c] == '.': '_' else: g[c])
    for gv in puz.givens: pins.add b36[idx(gv.pos)]
    var words: seq[string]
    for clue in puz.clues: words.add clue.word
    orderedLetters() & "~" & words.join("-") & "~" & paths & "~" & board & "~" & pins
  proc loadState(code: string): bool =
    let parts = code.split('~')
    if parts.len != 5 or parts[3].len != 36: return false
    let words = parts[1].split('-')
    if not loadSet(words.join(" ")): return false
    document.getElementById("custom").setValue(cstring(words.join(" ")))
    var ls = parts[0]
    var sorted = ls
    sorted.sort()
    var mine = puz.letters
    mine.sort()
    if sorted != mine: return false
    puz.letters = ls
    var b = emptyBoard()
    for c in 0 ..< 36:
      let ch = parts[3][c]
      if ch != '_':
        if ch notin ls or b.freeTile(ch) < 0: return false
        b.putAt(c, ch)
    let ps = parts[2].split('-')
    for i in 0 ..< min(ps.len, wpath.len):
      for ch in ps[i]:
        let c = b36.find(ch)
        if c >= 0: wpath[i].add c
    for ch in parts[4]:
      let c = b36.find(ch)
      if c >= 0 and b.cells[c] >= 0: puz.givens.add Given(pos: (row: c div 6, col: c mod 6), letter: letterOf(b.cells[c]))
    last = b
    lastPaths = wpath
    lastGivens = puz.givens
    stage.setState(b)
    say "Ripreso dallo stato salvato."
    true
  proc builderUrl(): string =
    site & "builder.html?s=" & stateCode()
  proc copied(e: Element, what: string) =
    let old = e.innerHTML
    e.innerHTML = "✓"
    say what
    discard setTimer(proc () = e.innerHTML = old, 1200)
  proc puzzleJson(): (string, int) =
    ## the puzzle as puzzlepaw JSON (letters in the order below the board, pins, word starts), with its
    ## solution and, under "builder", the link that reopens this exact state; also how many solutions it has
    let lets = orderedLetters()
    var p: ps.Problem
    for i in 0 .. 5: p.letters[i] = lets[i]
    for gv in puz.givens: p.letterHints.add ps.HintLetter(pos: gv.pos, letter: gv.letter)
    for i, clue in puz.clues:
      if wpath[i].len > 0: p.wordHints.add ps.HintWord(pos: clue.pos, word: clue.word)
    let r = ps.solve(p, ps.defaultOptions(limit = 2, keep = 1))
    proc sep(k: int): string =
      if k > 0: result = ","
    var j = "{\"problem\":{\"letters\":["
    for i in 0 .. 5: j.add sep(i) & "\"" & lets[i] & "\""
    j.add "],\"letterHints\":["
    for k, h in p.letterHints:
      j.add sep(k) & &"{{\"pos\":[{h.pos.row},{h.pos.col}],\"letter\":\"{h.letter}\"}}"
    j.add "],\"wordHints\":["
    for k, h in p.wordHints:
      j.add sep(k) & &"{{\"pos\":[{h.pos.row},{h.pos.col}],\"word\":\"{h.word}\"}}"
    j.add "]}"
    if r.solutions.len > 0:
      j.add ",\"solution\":["
      for row in 0 .. 5:
        j.add sep(row) & "["
        for col in 0 .. 5: j.add sep(col) & "\"" & r.solutions[0][row][col] & "\""
        j.add "]"
      j.add "]"
    j.add ",\"builder\":\"" & builderUrl() & "\"}"
    (j, r.count)
  document.getElementById("save").addEventListener("click", proc (ev: Event) =
    let (j, n) = puzzleJson()
    copyText(cstring(j))
    var note = "Copiato il JSON, ma il puzzle ha più soluzioni: aggiungi indizi 📌 prima di metterlo nel gioco."
    if n == 1: note = "Copiato il puzzle (JSON con soluzione e stato del builder). Incollalo in chat per aggiungerlo al gioco."
    if n == 0: note = "Copiato il JSON, ma questo puzzle non ha soluzioni: non si può ancora giocare."
    copied(document.getElementById("save"), note))
  proc randomInt(n: int): int {.importjs: "Math.floor(Math.random() * #)".}
  let uBox = document.getElementById("nou")
  uBox.addEventListener("change", proc (ev: Event) =
    noUTurn = uBox.checked
    refresh())
  solsEl.addEventListener("click", proc (ev: Event) =
    let k = dataK(ev)
    if k.isNil: return
    fitShown = parseInt($k)
    showFit()
    stage.draw(stage.state)
    showFits())
  document.getElementById("link").addEventListener("click", proc (ev: Event) =
    copyText(cstring(playUrl & playCode()))
    copied(document.getElementById("link"), "Copiato il link per giocare questo puzzle."))

  let startCode = $queryParam("s")
  if startCode.len == 0 or not loadState(startCode):
    document.getElementById("custom").setValue(cstring(sets[0]))
    discard loadSet(sets[0])

nbSave
