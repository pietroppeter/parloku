## The step solver: it solves a Parloku puzzle with moves a person can check, in this order of preference, and gives
## every move with its reason (in Italian, the game's language):
##   follow     the next letter of a word has one cell left next to the previous one (sometimes after trying the
##              other neighbour: the word can't be finished from there, or it would take another word's cells)
##   hidden     a letter has one cell left in a row, column or box
##   naked      a cell has one letter left
##   wordpoint, pointing   eliminations, only when nothing above works
## A word path never reuses a cell, and two words never share one. It never guesses: when no move works it stops,
## and `solved` says whether it got to the end. Pure Nim (no os), so the spiega page runs it in the browser.
import std/[strutils, sequtils, strformat]

type
  Step* = object
    kind*: string            ## givens, start, follow, wordpaths, hidden, naked, wordpoint, pointing
    cell*: int               ## placed cell (-1 for eliminations)
    letter*: char
    text*: string            ## the reason, in Italian
    unit*: seq[int]          ## highlighted cells (a row, column or box, or the word's path so far)
    word*: int               ## the word involved (-1: none)
    elims*: seq[(int, char)] ## eliminated candidates
    board*: string           ## the 36 cells after the step ('.' empty)
    cands*: seq[string]      ## each empty cell's letters still possible after the step

var letters: string
var words: seq[string]
var starts: seq[int]
var cand: array[36, set[char]]
var val: array[36, char]
var steps: seq[Step]
var givens: seq[(int, char)]

proc rc*(c: int): string = &"r{c div 6 + 1}c{c mod 6 + 1}"
proc nbrs(c: int): seq[int] =
  let (r, col) = (c div 6, c mod 6)
  if r > 0: result.add c - 6
  if r < 5: result.add c + 6
  if col > 0: result.add c - 1
  if col < 5: result.add c + 1

var units: seq[(string, seq[int])]
for r in 0..5: units.add (&"riga {r+1}", toSeq(0..5).mapIt(r*6+it))
for c in 0..5: units.add (&"colonna {c+1}", toSeq(0..5).mapIt(it*6+c))
for b in 0..5:
  var u: seq[int]
  for r in 0..1:
    for c in 0..2: u.add ((b div 2)*2+r)*6 + (b mod 2)*3 + c
  units.add (&"riquadro {b+1}", u)
proc peers(c: int): seq[int] =
  for (_, u) in units:
    if c in u:
      for x in u:
        if x != c and x notin result: result.add x

proc snapshot(s: var Step) =
  s.board = ""
  for c in 0..35: s.board.add(if val[c] == '\0': '.' else: val[c])
  s.cands = @[]
  for c in 0..35:
    var t = ""
    if val[c] == '\0':
      for l in letters:
        if l in cand[c]: t.add l
    s.cands.add t

proc place(c: int, l: char) =
  val[c] = l
  cand[c] = {l}
  for p in peers(c): cand[p].excl l

# ---- word paths
var allPaths: seq[seq[seq[int]]]
proc enumerate(w: int): seq[seq[int]] =
  var path: seq[int]
  var res: seq[seq[int]]
  let word = words[w]
  proc rec(c, k: int) =
    if c in path: return
    for j, s in starts:
      if j != w and s == c: return
    path.add c
    if k == word.len - 1: res.add path
    else:
      for n in nbrs(c): rec(n, k + 1)
    discard path.pop
  rec(starts[w], 0)
  res

proc pathOk(w: int, p: seq[int]): bool =
  for k, c in p:
    if words[w][k] notin cand[c]: return false
  # no other placed letter of a path... (cells with values must match: covered by cand)
  # sudoku inside the word: same letter twice in a unit
  for i in 0 ..< p.len:
    for j in i+1 ..< p.len:
      if words[w][i] == words[w][j] and p[j] in peers(p[i]): return false
  true

proc alivePaths(): seq[seq[seq[int]]] =
  ## paths of each word that fit the candidates and leave room for the other words (no shared cells)
  var single: seq[seq[seq[int]]]
  for w in 0 ..< words.len:
    var ps: seq[seq[int]]
    for p in allPaths[w]:
      if pathOk(w, p): ps.add p
    single.add ps
  result = newSeq[seq[seq[int]]](words.len)
  for w in 0 ..< words.len:
    for p in single[w]:
      # can the other words still be placed without touching p (and each other)?
      var others = toSeq(0 ..< words.len).filterIt(it != w)
      var used: seq[int] = p
      proc fit(i: int): bool =
        if i == others.len: return true
        for q in single[others[i]]:
          if q.anyIt(it in used): continue
          let n = used.len
          used.add q
          if fit(i + 1): return true
          used.setLen n
        false
      if fit(0): result[w].add p

proc commonPrefixReason(w: int, ps: seq[seq[int]], k: int): string =
  ## a human reason for "letter k of word w goes in ps[0][k]"
  let prev = ps[0][k-1]
  let word = words[w]
  if ps.allIt(it[k-1] == prev) and val[prev] != '\0':
    var free: seq[int]
    for n in nbrs(prev):
      if word[k] in cand[n] and n notin ps[0][0 ..< k] and not (n in starts and n != starts[w]): free.add n
    if free.len == 1:
      return &"{word}: dopo la {word[k-1]} in {rc(prev)} viene la {word[k]}, e tra le caselle accanto solo {rc(ps[0][k])} può ancora avere una {word[k]}."
    else:
      var why: seq[string]
      let prefix = ps[0][0 ..< k]
      for n in free:
        if n == ps[0][k]: continue
        var alone = false
        var blocked: seq[string]
        for q in allPaths[w]:
          if q[0 ..< k] == prefix and q[k] == n and pathOk(w, q):
            alone = true
            for o in 0 ..< words.len:
              if o == w: continue
              var room = false
              for r in allPaths[o]:
                if pathOk(o, r) and not r.anyIt(it in q): room = true
              if not room and words[o] notin blocked: blocked.add words[o]
        if alone:
          let who = if blocked.len > 0: blocked.join(" e ") else: "le altre parole"
          why.add &"da {rc(n)} la parola si potrebbe finire, però prenderebbe caselle che servono a {who}"
        else: why.add &"da {rc(n)} il resto di {word} non si riesce a scrivere"
      return &"{word}: dopo la {word[k-1]} in {rc(prev)} viene la {word[k]}. Accanto può stare in " & ($(free.mapIt(rc(it)).join(" o "))) &
        &", ma {why.join(\"; \")}. Resta {rc(ps[0][k])}."
  &"{word}: tutti i modi rimasti di scrivere la parola mettono la {word[k]} (lettera {k+1}) in {rc(ps[0][k])}."

proc tryFollow(): bool =
  let alive = alivePaths()
  for w in 0 ..< words.len:
    let ps = alive[w]
    if ps.len == 0: continue
    for k in 1 ..< words[w].len:
      let c = ps[0][k]
      if val[c] == '\0' and ps.allIt(it[k] == c):
        var s = Step(kind: "follow", cell: c, letter: words[w][k], word: w, unit: ps[0][0..k])
        s.text = commonPrefixReason(w, ps, k)
        if ps.len > 1 and not ps.allIt(it[0..k] == ps[0][0..k]): s.kind = "wordpaths"
        place(c, words[w][k])
        snapshot(s); steps.add s
        return true
  false

proc tryHidden(): bool =
  for (name, u) in units:
    for l in letters:
      if u.anyIt(val[it] == l): continue
      let places = u.filterIt(l in cand[it])
      if places.len == 1:
        let c = places[0]
        var s = Step(kind: "hidden", cell: c, letter: l, word: -1, unit: u)
        s.text = &"Nella {name} la {l} può andare solo in {rc(c)}."
        if name.startsWith("riquadro"): s.text = &"Nel {name} la {l} può andare solo in {rc(c)}."
        place(c, l)
        snapshot(s); steps.add s
        return true
  false

proc tryNaked(): bool =
  for c in 0..35:
    if val[c] == '\0' and cand[c].card == 1:
      var l: char
      for x in cand[c]: l = x
      var s = Step(kind: "naked", cell: c, letter: l, word: -1, unit: peers(c))
      s.text = &"In {rc(c)} non può stare nessun'altra lettera: riga, colonna e riquadro hanno già le altre cinque. Resta la {l}."
      place(c, l)
      snapshot(s); steps.add s
      return true
  false

proc tryWordElims(): bool =
  ## letter k of word w can only be in the cells S (over all alive paths): S inside a unit U
  ## takes that letter away from the rest of U. Also: a cell no word path can use keeps all letters.
  let alive = alivePaths()
  for w in 0 ..< words.len:
    let ps = alive[w]
    for k in 1 ..< words[w].len:
      let l = words[w][k]
      var S = ps.mapIt(it[k]).deduplicate
      for (name, u) in units:
        if S.allIt(it in u):
          var el: seq[(int, char)]
          for c in u:
            if c notin S and val[c] == '\0' and l in cand[c]: el.add (c, l)
          if el.len > 0:
            for (c, x) in el: cand[c].excl x
            var s = Step(kind: "wordpoint", cell: -1, letter: l, word: w, unit: S, elims: el)
            s.text = &"{words[w]}: la sua {l} (lettera {k+1}) può stare solo in " & S.mapIt(rc(it)).join(" o ") &
              &", tutte nella {name}: allora la {l} non va da nessun'altra parte nella {name} (" & el.mapIt(rc(it[0])).join(", ") & ")."
            snapshot(s); steps.add s
            return true
  # a cell that every path of word w uses, with letters from the word: keep only those letters
  for w in 0 ..< words.len:
    let ps = alive[w]
    if ps.len == 0: continue
    for c in 0..35:
      if val[c] != '\0': continue
      if ps.allIt(c in it):
        var ls: set[char]
        for p in ps: ls.incl words[w][p.find(c)]
        let el = toSeq(cand[c] - ls).mapIt((c, it))
        if el.len > 0:
          cand[c] = cand[c] * ls
          var s = Step(kind: "wordpoint", cell: -1, letter: ' ', word: w, unit: @[c], elims: el)
          s.text = &"{words[w]} passa per forza da {rc(c)}, con una lettera tra " & toSeq(ls).join("/") & ": le altre lettere lì non vanno."
          snapshot(s); steps.add s
          return true
  false

proc tryPointing(): bool =
  for (bname, b) in units[12..17]:
    for l in letters:
      if b.anyIt(val[it] == l): continue
      let S = b.filterIt(l in cand[it])
      for (name, u) in units[0..11]:
        if S.len > 1 and S.allIt(it in u):
          let el = u.filterIt(it notin b and l in cand[it] and val[it] == '\0').mapIt((it, l))
          if el.len > 0:
            for (c, x) in el: cand[c].excl x
            var s = Step(kind: "pointing", cell: -1, letter: l, word: -1, unit: S, elims: el)
            s.text = &"Nel {bname} la {l} sta per forza nella {name}: allora nel resto della {name} la {l} non c'è."
            snapshot(s); steps.add s
            return true
  false


proc explainSteps*(lettersIn: string, givensIn: seq[(int, char)], wordsIn: seq[string], startsIn: seq[int]): seq[Step] =
  ## every move from the given letters to the end (or to where it gets stuck)
  letters = lettersIn
  words = wordsIn
  starts = startsIn
  steps = @[]
  givens = @[]
  allPaths = @[]
  for c in 0 .. 35:
    val[c] = '\0'
    cand[c] = {}
    for l in letters: cand[c].incl l
  var s0 = Step(kind: "givens", cell: -1, word: -1)
  for (c, l) in givensIn:
    givens.add (c, l)
    place(c, l)
  s0.unit = givens.mapIt(it[0])
  s0.text = if givens.len == 0: "Non ci sono lettere date: si parte dalle parole." else:
    "Si parte dalle lettere date: " & givens.mapIt(&"{it[1]} in {rc(it[0])}").join(", ") & "."
  snapshot(s0); steps.add s0
  for w in 0 ..< words.len:
    allPaths.add enumerate(w)
  for w in 0 ..< words.len:
    var s = Step(kind: "start", cell: starts[w], letter: words[w][0], word: w, unit: @[starts[w]])
    s.text = &"{words[w]} parte dal suo cerchio in {rc(starts[w])}: lì c'è la {words[w][0]}."
    place(starts[w], words[w][0])
    snapshot(s); steps.add s
  while val.anyIt(it == '\0'):
    if tryFollow(): continue
    if tryHidden(): continue
    if tryNaked(): continue
    if tryWordElims(): continue
    if tryPointing(): continue
    break
  steps

proc solved*(steps: seq[Step]): bool =
  ## whether the moves fill the whole board
  steps.len > 0 and '.' notin steps[^1].board
