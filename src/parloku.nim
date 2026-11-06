import std/[json, os, algorithm, sequtils]
import nimib
import style, splash

nbInit
# write the page at the repo root (served by GitHub Pages), wherever the build is run from
let root = currentSourcePath().parentDir.parentDir
nb.doc.filename = root / "index.html"
nb.doc.context["title"] = %"Parloku"
nb.doc.context["stylesheet"] = %pageStyle
nb.doc.context["highlight"] = %""
nb.doc.context["disableHighlightJs"] = %true
func pageHeader(blk: JsonNode, nb: Nb): string =
  ""                                   # the title says it all: no header line above the game
nb.backend.partials["header"] = pageHeader

var gameBlocks: seq[NbBlock]           # the blocks index.html keeps; the rest is the devlog post (see the end)
nbRawHtml: """
<style>.kicker{font:700 .72rem/1.2 var(--font-body,sans-serif);letter-spacing:.12em;text-transform:uppercase;color:var(--muted);margin:1.6rem 0 .3rem}</style>
<p class="kicker">DEVLOG · HOW IT WORKS</p>
<h1>How it works</h1>
<p class="lede">The game's own notebook: the model, the rules as code, a solver that thinks like a person, the drag spec
and the browser runtime. Every block runs twice, while the page is built and in your browser.</p>
<p>Below is the game itself, then the Nim source that makes it, one piece at a time.</p>
"""
nbRawHtml: """
<div class="play" id="play">
<h1><span class="tile">P</span>arloku</h1>
<p class="lede" data-it="Un mini sudoku fatto di lettere, con delle parole nascoste.">A mini sudoku spelled in letters, with words hidden in it.</p>
<div class="game">
  <div class="picker"><button class="btn tut" id="tutorial" data-it="🎓<span class='tx'> tutorial</span>" aria-label="tutorial">🎓<span class="tx"> tutorial</span></button><a class="btn menu-only" id="howto" href="istruzioni.html" data-it="istruzioni">how to play</a><button class="btn menu-only" id="again" aria-haspopup="true" aria-expanded="false" data-it="ancora!">again!</button><span id="picker"></span>
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
      <button class="btn" id="redo" data-it="↷<span class='tx'> rifai</span>" aria-label="redo" disabled>↷<span class="tx"> redo</span></button>
      <button class="btn" id="hint" data-it="💡<span class='tx'> aiuto</span>" aria-label="hint">💡<span class="tx"> hint</span></button>
      <button class="btn" id="reset" aria-label="reset">↺ restart</button>
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
<div class="skins" id="skins" hidden></div>
</div>
"""
gameBlocks.add nb.blk

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
      marks: array[96, int]  # notes: bit li set when spot s has letter li noted; spots 0..35 are the cells,
                             # 36..95 the edges between two cells side by side (a Snyder note: in one of the two)
      small: bool            # small letters (notes): drags write notes instead of placing letters

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
Three functions carry the rules. `clashes` finds repeated letters in a row, column or box (on the board they tremble like restless marbles).
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
    ## the outline of every word on the board. Two words never share a cell: an outline never enters another
    ## word's start cell, and where two outlines could take the same letters, the longer one keeps them
    ## (on a tie, the word listed first) and the other is traced again around them.
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

nbText: "At build time the solver checks each puzzle has exactly one solution, and traces the clues through it:"

nbCode:
  for i, (title, code) in builtin:
    let p = decode(code)
    let sols = p.solve
    let verdict = if sols.len == 1: " (unique)" else: "s found, stopped"
    let key = if sols[0] == answerKeys[i]: "matches" else: "DIFFERS FROM"
    echo title, ": ", sols.len, " solution", verdict, ", ", key, " the answer key in data/"
    let ls = sols[0].outlines(p.clues)
    for i, clue in p.clues:
      let path = ls[i].mapIt(&"r{it div 6 + 1}c{it mod 6 + 1}")
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

  var lang = "it"            # Italian; English is a draft, only with ?lang=en
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
Tick the box and drag a tile on the board above: the faint squares are every board this drag can reach.
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
      cls: string            ## extra classes on its group (CSS may restyle it)
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
  proc stackPos(li: int): Vec = vec(150 + float(li mod 3) * 150, 546 + float(li div 3) * 74)   # two rows of three under the board

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
    # the body is what small-letter mode shrinks below the board; the hit square keeps the tile's full size to grab
    result = """<rect class="hit" x="-31" y="-31" width="62" height="62"/><g class="body">""" & shapes(li, cls) &
      &"""<text y="13" text-anchor="middle" font-size="36" class="glyph i{li}">{letter}</text></g>"""

  proc notesIn(marks: int): int =
    for j in 0 .. 5:
      if (marks and (1 shl j)) != 0: inc result

  proc edgeCells(s: int): (int, int) =
    ## the two cells either side of edge spot s (36..95): first 30 between a cell and the one on its right, then 30
    ## between a cell and the one below
    let e = s - 36
    if e < 30: ((e div 5) * 6 + e mod 5, (e div 5) * 6 + e mod 5 + 1)
    else: (e - 30, e - 30 + 6)

  proc maxNotes(s: int): int = (if s < 36: 4 else: 2)   # four in a cell, two by two; two on an edge

  proc spotCentre(s: int): Vec =
    if s < 36: return cellPos(s)
    let (a, b) = edgeCells(s)
    vec((cellPos(a).x + cellPos(b).x) / 2, (cellPos(a).y + cellPos(b).y) / 2)

  proc spotOpen(b: Board, s: int): bool =
    ## a spot can show and take notes while its cell, or both cells of its edge, are empty
    if s < 36: return b.cells[s] < 0
    let (c1, c2) = edgeCells(s)
    b.cells[c1] < 0 and b.cells[c2] < 0

  proc markPos(marks, s, li: int): Vec =
    ## where letter li's note sits in spot s, given the spot's notes, in the order of the letters below:
    ## in a cell two by two, on an edge one or two along it
    var k = 0
    for j in 0 ..< li:
      if (marks and (1 shl j)) != 0: inc k
    let p = spotCentre(s)
    if s < 36: return vec(p.x - 15 + float(k mod 2) * 30, p.y - 15 + float(k div 2) * 30)
    let along = if notesIn(marks) < 2: 0.0 else: float(k) * 24 - 12
    if s - 36 < 30: vec(p.x, p.y + along) else: vec(p.x + along, p.y)

  proc markSvg(li: int, edge: bool): string =
    ## a note is the letter's tile, small: the size of the small letters below the board (a bit smaller on an edge)
    let h = if edge: 12 else: 15
    &"""<rect class="hit" x="-{h}" y="-{h}" width="{2 * h}" height="{2 * h}"/><g class="note">{shapes(li)}""" &
      &"""<text y="13" text-anchor="middle" font-size="36" class="glyph i{li}">{puz.letters[li]}</text></g>"""

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
      let where = if c < 0: "home" else: ""
      result.add Item(key: &"t{id}", pos: pos, svg: svg, cls: where)
    # notes (small letters), in the empty cells only (a letter on the cell hides them; they come back when it goes)
    for s in 0 ..< 96:
      if b.marks[s] != 0 and b.spotOpen(s):
        for li in 0 .. 5:
          if (b.marks[s] and (1 shl li)) != 0:
            let cls = if s < 36: "mark" else: "mark side"
            result.add Item(key: &"m{s}-{li}", pos: markPos(b.marks[s], s, li), svg: markSvg(li, s >= 36), cls: cls)

nbText: """
And here is the entire interaction. Grabbing tile `id` lists one future per empty cell (a tile never replaces a letter already placed), snaps to the nearest within
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

  proc isHead(b: Board, at: int): bool =
    ## the letter on `at` is the last one spelled so far of some word: the head of its snake
    let g = b.grid
    let ls = g.outlines(puz.clues)
    for i, clue in puz.clues:
      let path = ls[i]
      if path.len > 0 and path[^1] == at: return true
    false

  proc mark(b: Board, c, li: int): Board =
    result = b
    result.marks[c] = b.marks[c] or (1 shl li)

  proc noteSpec(b: Board, li: int): Behavior[Board] =
    ## small letters: the held letter writes itself small into the empty cell it is over (a copy: no tile moves);
    ## anywhere else it goes back to its letter and nothing changes
    ## (a cell, or the edge between two empty cells side by side: a Snyder note, the letter is in one of the two)
    var spots: seq[int]
    for s in 0 ..< 96:                     # open spots with room for this note (or that have it already)
      if b.spotOpen(s) and (notesIn(b.marks[s]) < maxNotes(s) or (b.marks[s] and (1 shl li)) != 0): spots.add s
    result = proc (render: Render[Board], key: string): Picker[Board] =
      result.lands = spots.mapIt(markPos(b.mark(it, li).marks[it], it, li))
      result.pick = proc (p: Vec): Choice[Board] =
        result = Choice[Board](ok: true, state: b, land: vec(NaN, NaN), dist: Inf)
        # the nearest cell centre or edge middle wins: over the line between two cells, it is the edge
        var best = -1
        var bestD = Inf
        for s in 0 ..< 96:
          let d = norm(spotCentre(s) - p)
          if d < bestD and (s < 36 or b.spotOpen(s)):
            best = s
            bestD = d
        if best >= 0 and bestD < cell * 0.6 and best in spots:
          let nb = b.mark(best, li)
          result = Choice[Board](ok: true, state: nb, land: markPos(nb.marks[best], best, li), dist: bestD)

  proc tileSpec(b: Board, key: string): Behavior[Board] =
    if key[0] == 'm': return nil           # a note is never lifted itself: grabbing it pulls a copy
    let id = parseInt(key[1 .. ^1])
    let src = b.cells.find(id)
    if b.small:
      if src >= 0: return nil              # small letters move no letter on the board (grabbing one pulls a copy)
      return noteSpec(b, id div 6)
    if src >= 0 and isGiven(src): return nil
    var futures: seq[Board]
    for c in 0 ..< 36:                     # only empty cells: a tile never pushes out a letter already placed
      if not isGiven(c) and (b.cells[c] < 0 or c == src): futures.add b.place(id, c)
    var fallback = b.home(id)              # a tile from below goes back to its letter
    if src >= 0: fallback = b              # a tile lifted off the board stays in its cell
    closest(futures).within(cell * 0.6).orElse(closest(@[fallback]))

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
Around the tiles, the backdrop draws the board (clashes tremble, they are never painted red); the overlay draws each word's outline
on top: a ring on its start cell that grows around the letters as they are spelled. Both are plain functions of the board too, so nimib can also draw a
finished board at build time:
"""

nbCodeAnd(nbJsFromCode):
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
    for i in 1 .. 5:
      result.add &"""<line class="thin" x1="{bx}" y1="{by + i.float * cell}" x2="{bx + cell * 6}" y2="{by + i.float * cell}"/>"""
      result.add &"""<line class="thin" x1="{bx + i.float * cell}" y1="{by}" x2="{bx + i.float * cell}" y2="{by + cell * 6}"/>"""
    result.add &"""<rect class="edge" x="{bx}" y="{by}" width="{cell * 6}" height="{cell * 6}"/>"""
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
      if b.small and left[li] > 0:       # small letters: a thin round outline where the big letter was (its grab area too)
        result.add &"""<circle class="was" cx="{s.x}" cy="{s.y}" r="31"/>"""
      if left[li] == 0:
        result.add &"""<rect class="empty" x="{s.x - 31}" y="{s.y - 31}" width="62" height="62" rx="12"/>"""
        result.add &"""<text class="done" x="{s.x}" y="{s.y + 9}" text-anchor="middle" font-size="26">✓</text>"""

  proc overlay(b: Board): string =
    let g = b.grid
    let n = puz.clues.len
    let ls = g.outlines(puz.clues)
    for i, clue in puz.clues:
      # each word is an outline in its own dark colour: a ring on its start cell that grows around its letters
      let path = ls[i]
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
    if coachTarget >= 0:
      let p = cellPos(coachTarget)
      result.add &"""<rect class="aim pulse" x="{p.x - 37}" y="{p.y - 37}" width="74" height="74" rx="12"/>"""

  proc staticSvg(b: Board): string =
    maskTag = "sm"
    result = """<svg viewBox="40 -10 520 520"><defs><filter id="rough2"><feTurbulence type="fractalNoise" baseFrequency=".035" numOctaves="2" seed="7"/><feDisplacementMap in="SourceGraphic" scale="5"/></filter><filter id="cutout2"><feTurbulence type="fractalNoise" baseFrequency=".012" numOctaves="1" seed="3"/><feDisplacementMap in="SourceGraphic" scale="9"/></filter></defs>""" & backdrop(b)
    for it in renderBoard(b):
      if it.key[0] == 't' and b.cells.find(parseInt(it.key[1 .. ^1])) >= 0:
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
    targetHalf: float             # half the size of the drop-target outline
    centreGrab: bool              # the held item sits right under the pointer, wherever it was grabbed

  proc tr(p: Vec): cstring = cstring(&"translate({p.x:.2f}px, {p.y:.2f}px)")

  proc drawGhosts[S](st: Stage[S]) =
    var g = ""
    if st.dragKey.len > 0:
      if st.showGhosts:
        for l in st.picker.lands:
          if l.x == l.x: g.add &"""<circle class="land" cx="{l.x}" cy="{l.y}" r="6"/>"""
      if st.choice.ok and (st.targetAt.isNil or st.targetAt(st.choice.land)):
        let c = st.choice.land
        let h = st.targetHalf
        g.add &"""<rect class="target" x="{c.x - h}" y="{c.y - h}" width="{2 * h}" height="{2 * h}" rx="{h * 0.36:.1f}"/>"""
        if st.showGhosts:
          g.add &"""<line class="tether" x1="{st.at.x}" y1="{st.at.y}" x2="{c.x}" y2="{c.y}"/>"""
    st.ghosts.innerHTML = cstring(g)

  proc draw[S](st: Stage[S], s: S) =
    st.bg.innerHTML = cstring(st.backdrop(s))
    let items = st.render(s)
    var shown: seq[string]
    for it in items: shown.add it.key
    var gone: seq[string]
    for k in st.nodes.keys:                # an item this state does not draw (a note rubbed out) goes away
      if k notin shown: gone.add k
    for k in gone:
      st.fg.removeChild(st.nodes[k])
      st.nodes.del k
      st.looks.del k
    for it in items:
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
      let extra = if it.cls.len > 0: " " & it.cls else: ""
      n.setAttribute("class", cstring("item" & grab & lifted & extra))
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
    if st.centreGrab: st.grab = vec(0, 0)
    st.picker = behavior(st.render, key)   # speculative renders happen here
    st.fg.appendChild(st.nodes[key])       # float above the others
    st.svg.classList.add("dragging")
    st.move(p)

  proc finish[S](st: Stage[S]) =
    if st.dragKey.len == 0: return
    let key = st.dragKey
    let was = st.render.locate(st.state, key)
    let before = st.state
    if st.choice.ok: st.state = st.choice.state
    let now = st.render.locate(st.state, key)
    st.dragKey = ""
    st.svg.classList.remove("dragging")
    let n = st.nodes[key]
    # a copy let go nowhere, or a letter that left a note and went back: it melts into its letter, no glide
    let snap = (st.redirected or st.state != before) and now.x == was.x and now.y == was.y
    if snap: n.setStyle("transition", "none")
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
    let st = Stage[S](state: init, render: render, spec: spec, backdrop: backdrop, overlay: overlay, holdMs: 320, targetHalf: 36)
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
nbRawHtml: "</details>"

# ---------------------------------------------------------------- the game wiring (hidden)
var codes = ""
for (title, code) in builtin: codes.add "<option value=\"" & code & "\">" & title & "</option>"
nbRawHtml: "<template id=\"builtin\">" & codes & "</template>"
gameBlocks.add nb.blk

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
  var tutorial = false                 # the 🎓 tutorial runs on the first puzzle, with its own saved board
  let fromUrl = $search()
  if fromUrl.contains("p=") and decode(fromUrl).valid:
    code = decode(fromUrl).encode
    if games.allIt(it[0] != code): games.add (code, "")
  # ?demo: a practice board for the istruzioni page (in an iframe). It starts from the letters in &g= (cell+letter,
  # e.g. g=0I,1T), saves nothing, and has no menu
  let demo = fromUrl.contains("demo")
  # language: Italian, whatever the browser says. The English draft only by link (?lang=en)
  if fromUrl.contains("lang=en"): lang = "en"

  var solution: Grid
  var started = 0.0
  var wonAt = 0.0
  var celebrated = false

  proc emptyBoard(): Board = puz.boardOf(puz.startGrid)
  puz = decode(code)
  let stage = mount(host, 500, 664, emptyBoard(), renderBoard, tileSpec, backdrop, overlay, 50)   # cropped to the board: bigger on a phone
  # letters on the board stay put: grabbing one pulls out a copy of it (a double tap sends it back)
  stage.targetAt = proc (p: Vec): bool = p.y < by + 6 * cell   # only cells are targets: a letter going back below is not
  proc homeCopy(b: Board, li: int): string =
    ## a tile of letter li still below the board ("" when all six are on it)
    for k in 0 .. 5:
      if b.cells.find(li * 6 + k) < 0: return &"t{li * 6 + k}"
    ""
  stage.redirect = proc (b: Board, key: string): string =
    if key[0] == 'm':                      # a note: grabbing it pulls a copy of its letter, to write it elsewhere
      return homeCopy(b, parseInt(key.split('-')[1]))
    let id = parseInt(key[1 .. ^1])
    let at = b.cells.find(id)
    if at < 0: return key
    if b.small: return homeCopy(b, id div 6)   # small letters: any letter on the board, even a head, gives a copy
    if b.isHead(at): return ""             # a snake's head is drawn by hand (below): no copy
    for k in 0 .. 5:
      if b.cells.find((id div 6) * 6 + k) < 0: return &"t{(id div 6) * 6 + k}"
    ""
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
    if held.len > 0 and not stage.state.small:
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

  # ---- drawing a snake: hold its head and walk. Onto a free neighbour, the word's next letter is added;
  # back onto the cell before, the head letter goes back below. With no step taken, letting go on an empty
  # cell moves the head there.
  var snakeWord = -1
  var snakePath: seq[int]
  var snakeKey = ""
  var snakeStepped = false
  var snakeDown = vec(0, 0)
  var snakeBack = false                  # the finger is on the cell before the head: a back step, not done yet
  proc toBoard(ev: Event): Vec =
    let (l, t0, rw, rh) = rectOf(stage.svg)
    let c = clientXY(ev)
    vec(50 + (c.x - l) * 500 / rw, (c.y - t0) * 664 / rh)
  proc cellNear(p: Vec): int =
    ## the cell whose centre is close to p (-1 between cells or off the board)
    let (col, row) = (int(floor((p.x - bx) / cell)), int(floor((p.y - by) / cell)))
    if col notin 0 .. 5 or row notin 0 .. 5: return -1
    let c = row * 6 + col
    if norm(p - cellPos(c)) < cell * 0.42: c else: -1
  stage.svg.addEventListener("pointerdown", proc (ev: Event) =
    let k = keyAt(ev)
    snakeWord = -1
    if k.isNil or ($k)[0] != 't' or stage.state.small: return   # with small letters there are no snakes to draw
    let id = parseInt(($k)[1 .. ^1])
    let at = stage.state.cells.find(id)
    if at < 0: return
    let g = stage.state.grid
    let ls = g.outlines(puz.clues)
    for i, clue in puz.clues:            # an unfinished word first: its head is the one to grow
      let path = ls[i]
      if path.len > 0 and path[^1] == at and (snakeWord < 0 or path.len < clue.word.len):
        snakeWord = i
        snakePath = path
    if snakeWord < 0: return
    snakeKey = $k
    snakeStepped = false
    snakeBack = false
    snakeDown = toBoard(ev))
  proc backStep() =
    ## take the head's letter back below: the word is one letter shorter
    let head = snakePath[^1]
    discard snakePath.pop
    snakeBack = false
    snakeStepped = true
    stage.setState(stage.state.home(stage.state.cells[head]))
  proc growsTo(c: int): bool =
    ## can the word's next letter go on c, next to its head?
    let head = snakePath[^1]
    c >= 0 and stage.state.cells[c] < 0 and not isGiven(c) and snakePath.len < puz.clues[snakeWord].word.len and
      c notin othersStarts(puz.clues, snakeWord) and   # a word never runs over another word's start cell
      abs(c div 6 - head div 6) + abs(c mod 6 - head mod 6) == 1
  stage.svg.addEventListener("pointermove", proc (ev: Event) =
    if snakeWord < 0: return
    let p = toBoard(ev)
    let c = cellNear(p)
    if snakeBack and c >= 0 and c != snakePath[^2]:
      # the finger was on the cell before the head, and went on: backwards or a turn takes the head off,
      # anywhere else it was only on its way (Pietro, SERATA): no letter is taken off
      let before = snakePath[^1]
      snakePath.setLen(snakePath.len - 1)
      let turn = (snakePath.len >= 2 and c == snakePath[^2]) or (c != before and growsTo(c))
      snakePath.add before
      if turn: backStep()
      else: snakeBack = false
    let head = snakePath[^1]
    if c >= 0 and snakePath.len >= 2 and c == snakePath[^2] and not isGiven(head):
      snakeBack = true                   # back onto the cell before: the head goes below if the drag ends or goes on back
    elif growsTo(c):
      let word = puz.clues[snakeWord].word
      let li = puz.letters.find(word[snakePath.len])
      let b = stage.state
      for j in 0 .. 5:
        if b.cells.find(li * 6 + j) < 0:
          snakePath.add c
          snakeStepped = true
          stage.setState(b.place(li * 6 + j, c))
          break
    if not snakeStepped and norm(p - snakeDown) > 6 and not isGiven(head):
      let n = stage.nodes[snakeKey]      # no step yet: the head follows the finger, to be moved
      n.setAttribute("class", "item grab lifted")
      n.setStyle("transform", tr(p))
    elif snakeStepped:
      stage.draw(stage.state))
  let snakeUp = proc (ev: Event) =
    if snakeWord < 0: return
    let p = toBoard(ev)
    if snakeBack:
      let (col, row) = (int(floor((p.x - bx) / cell)), int(floor((p.y - by) / cell)))
      if col in 0 .. 5 and row in 0 .. 5 and row * 6 + col == snakePath[^2]:
        backStep()                       # let go on the cell before: the head goes below
        snakeWord = -1
        return
      snakeBack = false
    let w = snakeWord
    snakeWord = -1
    let head = snakePath[^1]
    if not snakeStepped and norm(p - snakeDown) > 6 and not isGiven(head):
      let (col, row) = (int(floor((p.x - bx) / cell)), int(floor((p.y - by) / cell)))
      let c = row * 6 + col
      if col in 0 .. 5 and row in 0 .. 5 and stage.state.cells[c] < 0 and not isGiven(c):
        stage.setState(stage.state.place(stage.state.cells[head], c))   # moved
        return
    discard w
    stage.draw(stage.state)              # glide back
  stage.svg.addEventListener("pointerup", snakeUp)
  stage.svg.addEventListener("pointercancel", snakeUp)

  # ---- small letters (notes): a swipe down in an empty spot of the letters below the board shrinks them, and from
  # then on a letter dragged onto an empty cell writes itself there small; a swipe up makes them big again
  var swipeFrom = vec(NaN, NaN)
  proc setSmall(on: bool) =
    if stage.state.small == on: return
    var b = stage.state
    b.small = on
    stage.setState(b)
  stage.svg.addEventListener("pointerdown", proc (ev: Event) =
    swipeFrom = vec(NaN, NaN)
    let p = toBoard(ev)
    if keyAt(ev).isNil and p.y > by + 6 * cell + 4: swipeFrom = p)
  stage.svg.addEventListener("pointermove", proc (ev: Event) =
    if swipeFrom.x != swipeFrom.x: return
    let d = toBoard(ev) - swipeFrom
    if abs(d.y) > 40 and abs(d.y) > 1.5 * abs(d.x):
      swipeFrom = vec(NaN, NaN)
      setSmall(d.y > 0))
  for e in ["pointerup", "pointercancel"]:
    stage.svg.addEventListener(cstring(e), proc (ev: Event) = swipeFrom = vec(NaN, NaN))

  proc sureLetter(g: Grid, c: int): char =
    ## the only letter a double tap can put in cell c: a start ring's first letter, or the one missing
    ## from a row, column or box that already has the other five, all different ('.': none)
    result = '.'
    for clue in puz.clues:
      if idx(clue.pos) == c: return clue.word[0]
    let (row, col) = (c div 6, c mod 6)
    var units: seq[seq[int]]
    units.add toSeq(0 .. 5).mapIt(row * 6 + it)
    units.add toSeq(0 .. 5).mapIt(it * 6 + col)
    let (r0, c0) = (row div 2 * 2, col div 3 * 3)
    units.add toSeq(0 .. 5).mapIt((r0 + it div 3) * 6 + c0 + it mod 3)
    for u in units:
      var seen: seq[char]
      for cc in u:
        if cc != c and g[cc] != '.' and g[cc] notin seen: seen.add g[cc]
      if seen.len == 5:
        for ch in puz.letters:
          if ch notin seen: return ch

  # ---- a double tap on a tile on the board sends it (and the rest of its word, from there on) back to its letter below; on an empty cell with only one possible letter (a start ring, or the last gap of a row, column or box), it fills that letter in
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
    if norm(up - downAt) > 8:              # a drag, not a tap
      tapKey = ""
      return
    if k.isNil:
      # a double tap on an empty start cell puts the word's first letter there
      let (l, t0, rw, rh) = rectOf(stage.svg)
      let x = 50 + (up.x - l) * 500 / rw
      let y = (up.y - t0) * 664 / rh
      let (col, row) = (int(floor((x - bx) / cell)), int(floor((y - by) / cell)))
      if col notin 0 .. 5 or row notin 0 .. 5:
        tapKey = ""
        return
      let c = row * 6 + col
      if stage.state.small:                # small letters: a double tap fills nothing in
        tapKey = ""
        return
      let forced = sureLetter(stage.state.grid, c)
      if forced == '.' or stage.state.cells[c] >= 0:
        tapKey = ""
        return
      let t = now()
      if tapKey == &"c{c}" and t - tapAt < 400:
        tapKey = ""
        let li = puz.letters.find(forced)
        for j in 0 .. 5:
          if stage.state.cells.find(li * 6 + j) < 0:
            stage.setState(stage.state.place(li * 6 + j, c))
            break
      else:
        tapKey = &"c{c}"
        tapAt = t
      return
    if ($k)[0] == 'm':                     # a double tap on a note rubs it out
      let t = now()
      if tapKey == $k and t - tapAt < 400:
        tapKey = ""
        let parts = ($k)[1 .. ^1].split('-')
        var b = stage.state
        b.marks[parseInt(parts[0])] = b.marks[parseInt(parts[0])] and not (1 shl parseInt(parts[1]))
        stage.setState(b)
      else:
        tapKey = $k
        tapAt = t
      return
    let id = parseInt(($k)[1 .. ^1])
    let at = stage.state.cells.find(id)
    if at < 0: return
    # inside a word, the word is cut there: this letter and every letter after it go back below,
    # the letters before it stay (and so do givens)
    var gone: seq[int]
    let g = stage.state.grid
    let ls = g.outlines(puz.clues)
    for i, clue in puz.clues:
      let path = ls[i]
      let k = path.find(at)
      if path.len >= 2 and k >= 0:
        for c in path[k .. ^1]:
          if c notin gone: gone.add c
    if gone.len == 0: gone.add at
    if gone.allIt(isGiven(it)): return
    let t = now()
    if tapKey == $k and t - tapAt < 400:
      tapKey = ""
      var b = stage.state
      for c in gone:
        if not isGiven(c) and b.cells[c] >= 0: b = b.home(b.cells[c])
      stage.setState(b)
    else:
      tapKey = $k
      tapAt = t)

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

  # ---- on the game page, only the game: tap an empty spot to show the rest, and again to hide it
  proc interactive(ev: Event): bool {.importjs:
    "!!#.target.closest('button,a,input,label,select,summary,.clues,.stage,.coach,.skins,.picker,.status,.sp')".}
  proc scrollTop() {.importjs: "window.scrollTo(0, 0)".}
  proc inPlay(ev: Event): bool {.importjs: "!!#.target.closest('.play')".}
  proc inBar(ev: Event): bool {.importjs: "!!#.target.closest('.picker,.undos')".}
  proc setVar(e: Element, k, v: cstring) {.importjs: "#.style.setProperty(#, #)".}
  proc onClue(ev: Event): bool {.importjs: "!!#.target.closest('.clue,button,a')".}
  proc inStage(ev: Event): bool {.importjs: "!!#.target.closest('.stage')".}
  var hideTimer = 0
  proc setMode(m: string)
  proc armHide() =
    ## the menu bar goes away by itself after a few idle seconds
    clearTimer(hideTimer)
    hideTimer = setTimer(proc () =
      if document.body.classList.contains("chrome"): setMode("focus"), 4000)
  proc setMode(m: string) =
    var drop = -1.0                    # -1: already down, keep the drop it has
    if m == "chrome" and not document.body.classList.contains("chrome"):
      let (_, barTop, _, barH) = rectOf(document.querySelector(".picker"))
      discard barTop
      let (_, cluesTop, _, _) = rectOf(document.getElementById("clues"))
      drop = max(0.0, barH + 6 - cluesTop)
      setVar(document.body, "--barh", cstring(&"{barH:.0f}px"))
    for k in ["focus", "chrome", "explain"]:
      if k == m: document.body.classList.add(cstring(k))
      else: document.body.classList.remove(cstring(k))
    if m == "chrome":
      # move words, grid and letters down only as much as the bar needs (none if there is room above already)
      if drop >= 0: setVar(document.body, "--drop", cstring(&"{drop:.0f}px"))
      armHide()
    else:
      discard setTimer(proc () =          # back to the three buttons once the bar is out of sight
        if not document.body.classList.contains("chrome"):
          document.querySelector(".picker").classList.remove("listing"), 400)
  proc inDevlog(): bool {.importjs: "location.pathname.includes('/devlog/')".}
  # the game page shows only the game; the devlog post (the same notebook) shows the game as a plain block in the page
  var playEl = document.getElementById("play")
  if demo:
    # tell the istruzioni page how tall this practice board is, so its frame fits it
    proc tellHeight() {.importjs:
      "(() => { const p = document.querySelector('.play'); if (p && parent !== window) parent.postMessage({parlokuHeight: Math.ceil(p.getBoundingClientRect().height + 4)}, '*') })()".}
    document.body.classList.add("demo")
    discard setTimer(proc () = tellHeight(), 50)
    discard setTimer(proc () = tellHeight(), 800)   # again once the fonts are in
    window.addEventListener("resize", proc (ev: Event) = tellHeight())
  if inDevlog(): playEl = nil
  if not playEl.isNil:
    setMode("focus")
    # one menu bar, at the top only: the puzzles and restart
    let bar = document.querySelector(".picker")
    bar.appendChild(document.getElementById("reset"))
    # ↶ and ↷ come down with the menu, on their own at the top right, next to the first word
    let undos = document.createElement("div")
    undos.className = "undos"
    undos.appendChild(document.getElementById("undo"))
    undos.appendChild(document.getElementById("redo"))
    document.querySelector(".game").appendChild(undos)
    for ev in ["pointerdown"]:
      undos.addEventListener(cstring(ev), proc (e: Event) = armHide())
    for ev in ["pointerdown", "scroll"]:
      bar.addEventListener(cstring(ev), proc (e: Event) = armHide())
    document.addEventListener("click", proc (ev: Event) =
      # a tap above the words brings the menu down; with the menu down, any tap outside it sends it back up
      if document.body.classList.contains("chrome"):
        if not inBar(ev): setMode("focus")
        return
      if document.body.classList.contains("focus"):
        # the menu's zone: anywhere above the grid that is not a word (a word wiggles instead)
        if onClue(ev) or inStage(ev): return
        let (_, gridTop, _, _) = rectOf(host)
        if clientXY(ev).y < gridTop and not demo: setMode("chrome")
        return
      if interactive(ev): return
      if inPlay(ev):
        setMode("focus")
        scrollTop())

  let banner = document.createElement("div")
  banner.className = "banner"
  host.appendChild(banner)
  let confetti = document.createElement("div")
  confetti.className = "confetti"
  host.appendChild(confetti)

  # ---- solved puzzles are remembered on this device, and ticked in the "again!" list
  proc solvedCodes(): seq[string] =
    let v = lsGet("parloku:solved")
    if not v.isNil and ($v).len > 0: result = ($v).split(',')
  proc markSolved(c: string) =
    if demo: return
    var cs = solvedCodes()
    if c notin cs:
      cs.add c
      lsSet("parloku:solved", cstring(cs.join(",")))
  proc renderPicker() =
    let done = solvedCodes()
    var html = ""
    for i, (gc, title) in games:
      var cls = ""
      if gc == code and not tutorial: cls.add " on"
      if gc in done: cls.add " done"
      let name = if title == "": L("from the link", "dal link") else: title
      let tick = if gc in done: "✓" else: ""
      html.add &"""<button class="btn num{cls}" data-i="{i}" aria-label="{L("puzzle", "puzzle")} {i + 1}: {name}"><span class="ck">{tick}</span>{name}</button>"""   # named by its three words
    pickerEl.innerHTML = cstring(html)

  proc clock(): string =
    let t0 = if wonAt > 0: wonAt else: now()
    let s = if started > 0: int((t0 - started) / 1000) else: 0
    &"{s div 60}:{s mod 60:02}"


  proc showClues() =
    let g = stage.state.grid
    var html = ""
    let ls = g.outlines(puz.clues)
    for i, clue in puz.clues:
      let path = ls[i]
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

  proc storeKey(): cstring =
    let prefix = if tutorial: "parloku:tutorial:" else: "parloku:"
    cstring(prefix & code)
  proc save() =
    if demo: return
    let small = if stage.state.small: "1" else: "0"
    lsSet(storeKey(), cstring(stage.state.cells.join(",") & ";" & $stage.state.moves & ";" & $started & ";" & $wonAt &
      ";" & stage.state.marks.join(",") & ";" & small))

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
  var coachMoved = false               # tutorial: the player dragged the blob, so it stays where they put it
  var taughtAt: array[StepKind, int]   # tutorial: the step where each gesture was first explained (-1: not yet)
  proc showCoach()
  proc refresh() =
    let g = stage.state.grid
    let won = solved(puz, g)
    if won and wonAt == 0: wonAt = now()
    if won and not tutorial and code notin solvedCodes():
      markSolved(code)
      renderPicker()
    if won and not celebrated:
      celebrated = true
      banner.innerHTML = cstring(&"<b>Bravo!</b><span>{stage.state.moves} " & L("moves", "mosse") & &" · {clock()}</span>")
      celebrate()
    if won: host.classList.add("won")
    else: host.classList.remove("won")
    showClues()
    showCoach()

  var history: seq[Board]               # boards before each change, for ↶ undo
  var future: seq[Board]                # boards undone, for ↷ redo (a new move forgets them)
  var last = stage.state
  let undoBtn = document.getElementById("undo")
  let redoBtn = document.getElementById("redo")
  proc setDisabled(e: Element, d: bool) {.importjs: "#.disabled = #".}
  var undoable = false                  # the restart button reads "undo restart" (below)
  var quiet = false                     # our own setState calls, which are not the player's moves
  var before: Board                     # the board, its history and clock before the restart
  var beforeHistory, beforeFuture: seq[Board]
  var beforeStarted, beforeWon = 0.0
  var undoTimer = 0
  var endUndoCb: proc ()                # set below, with the restart button
  var afterChange: proc ()              # set below: shows or hides the restart button
  stage.onCommit = proc () =
    if stage.state.small:
      stage.svg.classList.add("small")
      stage.targetHalf = 16                # the drop target is the note's own spot
      stage.centreGrab = true              # a small letter grabbed anywhere in its outline comes under the finger
    else:
      stage.svg.classList.remove("small")
      stage.targetHalf = 36
      stage.centreGrab = false
    if started == 0 and stage.state.moves > 0: started = now()
    # a move: a letter placed or taken, or a note written or rubbed out (switching the letters' size is not one);
    # undo and redo set `last` first
    let moved = stage.state.cells != last.cells or stage.state.marks != last.marks
    if undoable and not quiet and moved: endUndoCb()   # no going back to before the restart
    if moved:
      history.add last
      future = @[]
      last = stage.state
    undoBtn.setDisabled(history.len == 0)
    redoBtn.setDisabled(future.len == 0)
    refresh()
    save()
    if not afterChange.isNil: afterChange()

  proc load(c: string) =
    code = c
    puz = decode(c)
    let sols = puz.solve(limit = 1)
    for i in 0 ..< 36: solution[i] = '.'
    if sols.len > 0: solution = sols[0]
    var b = emptyBoard()
    b.small = stage.state.small          # the letters stay small (or big) from one puzzle to the next
    started = 0
    wonAt = 0
    let saved = if demo: nil else: lsGet(storeKey())
    if demo:
      let gi = fromUrl.find("&g=")
      if gi >= 0:
        for item in fromUrl[gi + 3 .. ^1].split('&')[0].split(','):
          if item.len < 2: continue
          let c = parseInt(item[0 .. ^2])
          let li = puz.letters.find(item[^1])
          if li < 0 or c notin 0 ..< 36 or b.cells[c] >= 0: continue
          for k in 0 .. 5:
            if b.cells.find(li * 6 + k) < 0:
              b = b.place(li * 6 + k, c)
              break
    if not saved.isNil:
      let parts = ($saved).split(';')
      let cells = parts[0].split(',')
      if parts.len in [4, 6] and cells.len == 36:
        for i in 0 ..< 36: b.cells[i] = parseInt(cells[i])
        b.moves = parseInt(parts[1])
        started = parseFloat(parts[2])
        wonAt = parseFloat(parts[3])
        if parts.len == 6:                 # the notes and the small-letter mode
          let ms = parts[4].split(',')
          if ms.len in [36, 96]:
            for i in 0 ..< ms.len: b.marks[i] = parseInt(ms[i])
          b.small = parts[5] == "1"
    celebrated = solved(puz, b.grid)     # don't throw confetti again on reload
    confetti.innerHTML = ""
    banner.innerHTML = cstring(&"<b>Bravo!</b><span>{b.moves} " & L("moves", "mosse") & &" · {clock()}</span>")
    renderPicker()
    history = @[]
    future = @[]
    last = b
    stage.setState(b)
    undoBtn.setDisabled(true)
    redoBtn.setDisabled(true)


  proc dataI(ev: Event): cstring {.importjs: "(#.target.closest('[data-i]')?.dataset.i ?? null)".}
  let againBtn = document.getElementById("again")
  againBtn.addEventListener("click", proc (ev: Event) =
    document.querySelector(".picker").classList.add("listing")   # the three buttons give way to the puzzles
    armHide())

  # ---- changing puzzle: words, grid and letters leave to the left one at a time, and the new ones come in from the right
  proc slideOutSvg(e: Element, dx: float, delay: int) {.importjs:
    "#.animate([{transform: 'translateX(0px)'}, {transform: 'translateX(' + # + 'px)'}], {duration: 260, delay: #, easing: 'ease-in', fill: 'both'})".}
  proc slideInSvg(e: Element, dx: float, delay: int) {.importjs:
    "#.animate([{transform: 'translateX(' + # + 'px)'}, {transform: 'translateX(0px)'}], {duration: 300, delay: #, easing: 'ease-out', fill: 'both'})".}
  proc slideOut(e: Element, dx: float, delay: int) {.importjs:
    "#.animate([{transform: 'translateX(0px)', opacity: 1}, {transform: 'translateX(' + # + 'px)', opacity: 0}], {duration: 260, delay: #, easing: 'ease-in', fill: 'both'})".}
  proc slideIn(e: Element, dx: float, delay: int) {.importjs:
    "#.animate([{transform: 'translateX(' + # + 'px)', opacity: 0}, {transform: 'translateX(0px)', opacity: 1}], {duration: 300, delay: #, easing: 'ease-out', fill: 'both'})".}
  proc stopAnims(e: Element) {.importjs: "#.getAnimations().forEach(a => a.cancel())".}
  proc kids(e: Element): seq[Element] {.importjs: "Array.from(#.children)".}
  proc clueEls(): seq[Element] {.importjs: "Array.from(document.querySelectorAll('.clues .clue'))".}
  proc viewW(): float {.importjs: "(window.innerWidth)".}
  proc lessMotion2(): bool {.importjs: "matchMedia('(prefers-reduced-motion: reduce)').matches".}
  const step = 90                      # ms between one piece and the next
  proc pieces(): seq[(seq[Element], bool)] =
    ## in order: each word, then the grid (with the letters on it), then each of the six letters below; true for SVG parts
    for c in clueEls(): result.add (@[c], false)
    var grid = @[stage.bg, stage.top]
    var below: array[6, seq[Element]]
    for id in 0 ..< 36:
      let n = stage.nodes.getOrDefault(&"t{id}")
      if n.isNil: continue                 # move a tile's insides: the tile itself is placed by its own transform
      if stage.state.cells.find(id) >= 0: grid.add n.kids
      else: below[id div 6].add n.kids
    result.add (grid, true)
    for row in below: result.add (row, true)
  var switching = false
  proc switchTo(c: string) =
    proc go() =
      tutorial = false
      lsSet(cstring("parloku:" & c), "")   # picking a puzzle always starts it afresh
      load(c)
      pushQuery(cstring("p=" & code))
    if lessMotion2():
      go()
      return
    switching = true
    let gone = pieces()
    for j, (els, svg) in gone:
      for e in els:
        if svg: e.slideOutSvg(-640, j * step)
        else: e.slideOut(-viewW(), j * step)
    discard setTimer(proc () =
      go()
      let inn = pieces()
      for j, (els, svg) in inn:
        for e in els:
          if svg: e.slideInSvg(640, j * step)
          else: e.slideIn(viewW(), j * step)
      discard setTimer(proc () =
        for (els, _) in pieces():
          for e in els: e.stopAnims()
        switching = false, inn.len * step + 320), gone.len * step + 280)

  pickerEl.addEventListener("click", proc (ev: Event) =
    let i = dataI(ev)
    if i.isNil or switching: return
    let c = games[parseInt($i)][0]
    if not playEl.isNil: setMode("focus")
    if c == code and not tutorial: return          # the puzzle already in play: just close the menu
    endUndoCb()
    switchTo(c))

  # ---- restart right away, no "sure?": for a few seconds, until the next move, the button offers to undo it
  let resetBtn = document.getElementById("reset")
  proc showReset() =
    ## restart is only offered once a letter is down (or while its undo is on offer)
    var placed = false
    for c in 0 ..< 36:
      if stage.state.cells[c] >= 0 and not isGiven(c): placed = true
    for m in stage.state.marks:
      if m != 0: placed = true
    resetBtn.setHidden(not placed and not undoable)
  proc resetLabel() =
    if undoable: resetBtn.innerHTML = cstring(L("↶ undo restart", "↶ annullo rifaccio"))
    else: resetBtn.innerHTML = cstring(L("↺ restart", "↺ rifaccio"))
    showReset()
  proc endUndo() =
    if not undoable: return
    undoable = false
    clearTimer(undoTimer)
    resetLabel()
    if document.body.classList.contains("chrome"): armHide()
  endUndoCb = endUndo
  afterChange = showReset
  resetLabel()
  resetBtn.addEventListener("click", proc (ev: Event) =
    if undoable:                        # put back the board as it was before the restart
      undoable = false
      clearTimer(undoTimer)
      quiet = true
      stage.setState(before)
      quiet = false
      history = beforeHistory
      future = beforeFuture
      last = stage.state
      started = beforeStarted
      wonAt = beforeWon
      celebrated = solved(puz, stage.state.grid)
      undoBtn.setDisabled(history.len == 0)
      redoBtn.setDisabled(future.len == 0)
      save()
      refresh()
      resetLabel()
      armHide()
      return
    var had = false                     # nothing to undo on an untouched board
    for c in 0 ..< 36:
      if stage.state.cells[c] >= 0 and not isGiven(c): had = true
    for m in stage.state.marks:
      if m != 0: had = true
    before = stage.state
    beforeHistory = history
    beforeFuture = future
    beforeStarted = started
    beforeWon = wonAt
    lsSet(storeKey(), "")
    quiet = true
    load(code)
    quiet = false
    if had:
      undoable = true
      resetLabel()
      clearTimer(hideTimer)             # keep the menu up while undo is on offer
      undoTimer = setTimer(proc () = endUndo(), 8000))

  undoBtn.addEventListener("click", proc (ev: Event) =
    if history.len == 0: return
    endUndoCb()
    future.add stage.state
    last = history.pop
    last.small = stage.state.small     # undo and redo leave the letters' size as it is
    stage.setState(last)
    armHide())
  redoBtn.addEventListener("click", proc (ev: Event) =
    if future.len == 0: return
    endUndoCb()
    history.add stage.state
    last = future.pop
    last.small = stage.state.small     # undo and redo leave the letters' size as it is
    stage.setState(last)
    armHide())

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

  # ---- tap a clue word: its start ring (or its outline so far) wiggles on the board, to show where it is
  cluesEl.addEventListener("click", proc (ev: Event) =
    let i = hoverIndex(ev)
    if i.isNil: return
    wiggleClue = parseInt($i)
    stage.top.innerHTML = cstring(overlay(stage.state))
    discard setTimer(proc () =
      wiggleClue = -1
      if stage.dragKey.len == 0: stage.top.innerHTML = cstring(overlay(stage.state)), 700))

  # ---- the 🎓 tutorial: a coach floating over the game that asks the logical path for the next move after every drop

  proc buttons(acts: seq[(string, string)]): string =
    for (act, label) in acts: result.add &"""<button class="btn" data-act="{act}">{label}</button>"""

  proc introText(): string =
    case intro
    of 0: L("Welcome! <b>Spoiler warning:</b> this tutorial solves the first puzzle with you, step by step. To try it on your own first, tap <i>exit</i>. Fill the grid with the six letters <b>A I L P S T</b>, pulling copies out of the six letters below the board.",
            "Benvenuto! <b>Attenzione, spoiler:</b> questo tutorial risolve con te il primo puzzle, passo per passo. Se vuoi provarci prima da solo, tocca <i>esci</i>. Riempi la griglia con le sei lettere <b>A I L P S T</b>, tirando fuori delle copie dalle sei lettere sotto la griglia.")
    of 1: L("As in sudoku, each letter appears once in every row, every column and every 2×3 box. One of each is highlighted.",
            "Come nel sudoku, ogni lettera compare una volta in ogni riga, in ogni colonna e in ogni riquadro 2×3. Ne vedi evidenziato uno per tipo.")
    of 2: L("The three words above are the clues. Each one starts in the cell ringed in its colour and goes one step at a time: up, down, left or right.",
            "Le tre parole in alto sono gli indizi. Ognuna parte dalla casella con il cerchio del suo colore e procede un passo alla volta: in su, in giù, a destra o a sinistra.")
    else: L("The method: first put the first letter of every word. Then follow each word letter by letter. When the sudoku leaves only one cell for the next letter, that letter is forced. Let's start!",
            "Il metodo: prima metti la prima lettera di ogni parola. Poi segui ogni parola lettera per lettera. Quando il sudoku lascia una sola casella per la lettera dopo, quella lettera è obbligata. Cominciamo!")

  # where the coach's blob goes: the free spot nearest the step's target. It must not cover the target cell,
  # the letter to pull or the clue (weight 100), and had better not cover the cells it names (weight 1)
  type Box = tuple[x, y, w, h: float]
  proc toScreen(svg: Element, x, y: float): Vec {.importjs:
    "((s, x, y) => { const m = s.getScreenCTM(); return {x: m.a * x + m.c * y + m.e, y: m.b * x + m.d * y + m.f}; })(#, #, #)".}
  proc viewH(): float {.importjs: "(window.innerHeight)".}
  proc svgBox(c: Vec, r: float): Box =
    let a = toScreen(stage.svg, c.x - r, c.y - r)
    let b = toScreen(stage.svg, c.x + r, c.y + r)
    (a.x, a.y, b.x - a.x, b.y - a.y)
  proc elBox(e: Element): Box =
    let (x, y, w, h) = rectOf(e)
    (x, y, w, h)
  proc overlapArea(a, b: Box): float =
    max(0.0, min(a.x + a.w, b.x + b.w) - max(a.x, b.x)) * max(0.0, min(a.y + a.h, b.y + b.h) - max(a.y, b.y))
  proc placeCoach() =
    if not coachEl.attr("hidden").isNil or coachMoved: return
    var must, nice: seq[Box]
    if coachTarget >= 0: must.add svgBox(cellPos(coachTarget), cell / 2)
    for li in coachStacks: must.add svgBox(stackPos(li), 34)
    if tutorial and intro >= 4 and coachStep.kind == skWord and coachTarget >= 0:
      must.add svgBox(cellPos(coachStep.path[^2]), cell / 2)   # the word's last letter, to stretch it from
    for c in coachTint: nice.add svgBox(cellPos(c), cell / 2)
    var clues: seq[int]
    if tutorial and intro == 2: clues = toSeq(0 ..< puz.clues.len)
    elif tutorial and intro >= 4 and coachStep.kind in {skStart, skWord}: clues = @[coachStep.clue]
    for i in 0 ..< puz.clues.len:
      let e = cluesEl.querySelector(cstring(&"[data-clue=\"{i}\"]"))
      if e.isNil: continue
      if i in clues: must.add elBox(e) else: nice.add elBox(e)
    coachEl.setAttr("data-clues", cstring(clues.join(",")))   # for tests/gestures/tutorial.js
    for b in must.mitems: b = (b.x - 8, b.y - 8, b.w + 16, b.h + 16)   # a little air round what matters
    let me = elBox(coachEl)
    let goal = if must.len > 0: must[0].y + must[0].h / 2 else: viewH() / 2
    var best = 8.0
    var bestCost = 1e18
    var y = 8.0
    while y + me.h <= viewH() - 8 or y == 8.0:
      let at: Box = (me.x, y, me.w, me.h)
      var cost = abs(y + me.h / 2 - goal) / 1000
      for b in must: cost += 100 * overlapArea(at, b)
      for b in nice: cost += overlapArea(at, b)
      if cost < bestCost: (best, bestCost) = (y, cost)
      y += 4
    coachEl.style.top = cstring(&"{best:.0f}px")

  window.addEventListener("resize", proc (ev: Event) = placeCoach())

  # the player can move the blob out of the way: drag it anywhere but its buttons
  proc onBtn(ev: Event): bool {.importjs: "!!#.target.closest('button')".}
  proc viewWidth(): float {.importjs: "(window.innerWidth)".}
  var coachGrab = vec(-1, -1)            # where the finger holds the blob, inside it (-1: not held)
  coachEl.addEventListener("pointerdown", proc (ev: Event) =
    if onBtn(ev): return
    let (x, y, _, _) = rectOf(coachEl)
    let p = clientXY(ev)
    coachGrab = vec(p.x - x, p.y - y)
    coachEl.capture(ev)
    coachEl.classList.add("held")
    ev.preventDefault())
  coachEl.addEventListener("pointermove", proc (ev: Event) =
    if coachGrab.x < 0: return
    let (_, _, w, h) = rectOf(coachEl)
    let p = clientXY(ev)
    let x = max(0.0, min(viewWidth() - w, p.x - coachGrab.x))
    let y = max(0.0, min(viewH() - h, p.y - coachGrab.y))
    coachMoved = true
    coachEl.style.left = cstring(&"{x:.0f}px")
    coachEl.style.right = "auto"
    coachEl.style.margin = "0"
    coachEl.style.top = cstring(&"{y:.0f}px"))
  for name in ["pointerup", "pointercancel"]:
    coachEl.addEventListener(cstring(name), proc (ev: Event) =
      coachGrab = vec(-1, -1)
      coachEl.classList.remove("held"))

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
        # how to do it: the gestures, taught in full the first time, then only named
        let first = taughtAt[s.kind] < 0 or taughtAt[s.kind] == s.cell
        taughtAt[s.kind] = s.cell
        let drag = L(&" Drag {an(s.letter)} <b>{s.letter}</b> there", &" Trascina lì una <b>{s.letter}</b>")
        case s.kind
        of skFix:
          text.add L(" Or double tap it: it goes back by itself (inside a word, the letters after it go back too).",
                     " Oppure fai doppio tocco sulla lettera: torna giù da sola (se è dentro una parola, tornano giù anche le lettere dopo).")
        of skStart:
          if first:
            text.add drag & L(", or double tap the cell: a word's first letter goes in by itself.",
                              ", oppure fai doppio tocco sulla casella: la prima lettera di una parola si mette da sola.")
          else: text.add L(" Or double tap the cell.", " Oppure doppio tocco sulla casella.")
        of skWord:
          let w = puz.clues[s.clue].word
          let (a, z) = (rc(s.path[^2]), rc(s.cell))
          if first:
            text.add L(&" Stretch <b>{w}</b>: drag its last letter, from {a} to {z}, and the {s.letter} comes by itself.",
                       &" Allunga <b>{w}</b>: trascina la sua ultima lettera, da {a} a {z}, e la {s.letter} arriva da sola.")
          else: text.add L(&" Stretch <b>{w}</b> from {a} to {z}.", &" Allunga <b>{w}</b> da {a} a {z}.")
        else:
          if sureLetter(g, s.cell) == s.letter:
            if first:
              text.add L(&" It's the last free cell of its row, column or box: double tap it and the {s.letter} goes in by itself.",
                         &" È l'ultima casella libera della sua riga, colonna o riquadro: fai doppio tocco e la {s.letter} si mette da sola.")
            else: text.add L(" Double tap and it goes in by itself.", " Doppio tocco e si mette da sola.")
          else: text.add drag & "."
        if s.kind notin {skFix, skWord}:      # a word grows from its last letter: no letter to pull from below
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
    placeCoach()
    nextFrame(proc (t: float) = placeCoach())   # once more, after the clues and the board have their final layout

  proc startTutorial() =
    tutorial = true
    intro = 0
    guided = true
    wordsAck = false
    for k in StepKind: taughtAt[k] = -1
    coachMoved = false
    for k in ["left", "right", "margin"]: coachEl.style.removeProperty(cstring(k))
    code = games[0][0]
    lsSet(storeKey(), "")
    load(code)

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

  # ---- Italian, or the English draft: the page is written in English, with the Italian in data-it
  proc applyLang() =
    setDocLang(cstring(lang))
    if lang == "it":
      for e in i18nNodes(): e.innerHTML = e.attr("data-it")
    load(code)

  # ---- the look: Niki de Saint Phalle, the game's one skin. Others only by link (?skin=name), for trying them out
  proc setSkin(e: Element, v: cstring) {.importjs: "#.dataset.skin = #".}
  var skin = "niki"
  let si = fromUrl.find("skin=")
  if si >= 0: skin = fromUrl[si + 5 .. ^1].split('&')[0]
  document.body.setSkin(cstring(skin))

  if fromUrl.contains("tutorial"):
    tutorial = true
    code = games[0][0]
  applyLang()

# ---------------------------------------------------------------- the daily splash and the first lesson (src/splash.nim)
nbRawHtml: splashHtml()                # the lesson brings its own example: it spoils no puzzle
gameBlocks.add nb.blk
let splashBlock = nb.blk
nbJsFromCodeGlobal:
  import src/splashrt                  # the splash's behaviour, in Nim: it starts by itself when the page has #splash

nbText: """
That's the game. Puzzles live in [`data/`](https://github.com/pietroppeter/parloku/tree/main/data) as puzzlepaw JSON,
and any puzzle can be played from a link such as `?p=AILPST_51S.23L.04P_00ITALIA.20PASTA.40ALPI`
(the 🔗 button copies it). Progress is kept in your browser, per puzzle.
The game speaks Italian. English is a draft, only by link (`?lang=en`), and `?tutorial` opens the 🎓 tutorial directly.

Built with [nimib](https://github.com/pietroppeter/nimib). Hit *show source* below for the whole notebook.
"""

# ---------------------------------------------------------------- two pages from one notebook
# The notebook, prose and code, is the devlog post "How it works". The game page, index.html, keeps only
# the game: the play block, the puzzle list, the splash and the compiled script. Both run the same script.
nb.nbCollectAllNbJs()
let allBlocks = nb.doc.blocks
func postHeader(blk: JsonNode, nb: Nb): string =
  """<header><span><a href="../../">parloku</a> · <a href="../">devlog</a></span><span>06 Nov 2026</span></header>"""
nb.backend.partials["header"] = postHeader
nb.doc.context["title"] = %"Parloku: how it works"
nb.doc.filename = root / "devlog" / "how-it-works" / "index.html"
nb.doc.blocks = allBlocks.filterIt(it != splashBlock)   # no daily hello in the middle of a read
write nb

func noFooter(blk: JsonNode, nb: Nb): string = ""
nb.backend.partials["header"] = pageHeader
nb.backend.partials["footer"] = noFooter              # no "show source" under the game: the post has it
nb.doc.context["title"] = %"Parloku"
nb.doc.filename = root / "index.html"
nb.doc.blocks = allBlocks.filterIt(it in gameBlocks or it of NbJsFromCodeOwnFile)
write nb
