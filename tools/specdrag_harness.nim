# ---- specdrag harness (appended after the game's shared code by tools/specdrag.nim)

type
  SdOutline = object
    word: string
    cells: seq[string]
  SdScenario = object
    cap, requirement, scenario, change, path: string
    line: int
    puzzle, gesture: string
    points: seq[string]
    start, finish: string
    outlines: seq[SdOutline]
    refused: bool

proc sdPuzzle(spec, dataDir: string): Puzzle =
  ## "2": the second puzzle file in data/ (puzzle2-*.json); anything else: a ?p= code
  if spec.len > 0 and spec.allIt(it in '0'..'9'):
    for f in walkFiles(dataDir / ("puzzle" & spec & "-*.json")):
      let j = parseFile(f)["problem"]
      result.letters = j["letters"].mapIt(it.getStr).join
      for h in j["letterHints"]:
        result.givens.add Given(pos: (h["pos"][0].getInt, h["pos"][1].getInt), letter: h["letter"].getStr[0])
      for h in j["wordHints"]:
        result.clues.add Clue(pos: (h["pos"][0].getInt, h["pos"][1].getInt), word: h["word"].getStr)
      return
    quit "specdrag: no data/puzzle" & spec & "-*.json"
  decode(spec)

proc sdCell(s: string): int =
  ## "r2c6" -> cell index
  if s.len == 4 and s[0] == 'r' and s[2] == 'c' and s[1] in '1'..'6' and s[3] in '1'..'6':
    return (ord(s[1]) - ord('1')) * 6 + ord(s[3]) - ord('1')
  -1

proc sdPoint(s: string): Vec =
  let c = sdCell(s)
  if c >= 0: return cellPos(c)
  if s.startsWith("stack "): return stackPos(puz.letters.find(s[6 .. ^1].strip[0]))
  if s == "off": return vec(560, 650)
  quit "specdrag: unknown waypoint " & s

proc sdGrid(b: Board): string =
  for ch in b.grid: result.add ch

proc sdShow(g: string): string =
  for r in 0 .. 5:
    result.add "      "
    for c in 0 .. 5: result.add g[r * 6 + c] & " "
    result.add "\n"

proc sdCellName(c: int): string = "r" & $(c div 6 + 1) & "c" & $(c mod 6 + 1)

# frames for the viewer: boards are drawn once each (strings shared through a table)
var sdStrings: seq[string]
var sdStringIx = initTable[string, int]()
proc sdStr(s: string): int =
  if s notin sdStringIx:
    sdStringIx[s] = sdStrings.len
    sdStrings.add s
  sdStringIx[s]

proc sdBoard(b: Board, tag: string): JsonNode =
  maskTag = tag
  var pos = newJObject()
  for it in renderBoard(b): pos[it.key] = %[round(it.pos.x, 1), round(it.pos.y, 1)]
  result = %*{"pos": pos, "bg": sdStr(backdrop(b)), "top": sdStr(overlay(b))}
  maskTag = "wm"

when isMainModule:
  let scen = parseFile(paramStr(1)).to(seq[SdScenario])
  let dataDir = paramStr(2)
  var outFrames = newJArray()
  var failed, pend, fixed = 0
  for n, s in scen:
    puz = sdPuzzle(s.puzzle, dataDir)
    var problems: seq[string]
    var g0: Grid
    for c in 0 ..< 36: g0[c] = (if c < s.start.len: s.start[c] else: '.')
    for gv in puz.givens:
      if g0[idx(gv.pos)] != gv.letter: problems.add "start board misses the given " & gv.letter & " at " & sdCellName(idx(gv.pos))
    var state = puz.boardOf(g0)
    var boards = newJArray()
    var frames = newJArray()
    var lastShown = ""
    var held = ""
    var tilesSvg = newJObject()
    for id in 0 ..< 36:
      tilesSvg["t" & $id] = %sdStr(tileSvg(id div 6, isGiven(state.cells.find(id))))
    proc frame(shown: Board, p: Vec, key: string) =
      let gs = shown.sdGrid & $shown.cells
      if gs != lastShown:
        boards.add sdBoard(shown, "s" & $n & "b" & $boards.len & "m")
        lastShown = gs
      frames.add %*{"b": boards.len - 1, "p": [round(p.x, 1), round(p.y, 1)], "k": key}
    if s.gesture in ["drag", "hold"] and s.points.len >= 2:
      let p0 = sdPoint(s.points[0])
      var grabbed = ""
      let c0 = sdCell(s.points[0])
      if c0 >= 0:
        if state.cells[c0] >= 0: grabbed = "t" & $state.cells[c0]
      else:
        let li = puz.letters.find(s.points[0][6 .. ^1].strip[0])
        for j in 0 .. 5:
          if state.cells.find(li * 6 + j) < 0:
            grabbed = "t" & $(li * 6 + j)
            break
      for k in 0 .. 3: frame(state, p0, "")
      when declared(extendFrom): extendFrom = -1
      var key = grabbed
      if grabbed.len > 0 and s.gesture == "drag": key = grabKey(state, grabbed)
      let behavior = if key.len > 0: tileSpec(state, key) else: nil
      if behavior.isNil:
        if not s.refused: problems.add "nothing can be grabbed at " & s.points[0]
        for k in 0 .. 5: frame(state, p0, "")
      else:
        if s.refused: problems.add "the tile at " & s.points[0] & " can be picked up"
        let origin = renderBoard.locate(state, grabbed)
        let picker = behavior(renderBoard, key)
        var choice: Choice[Board]
        var at = origin
        held = key
        for w in 1 ..< s.points.len:
          let target = sdPoint(s.points[w])
          let from0 = at
          for k in 1 .. 10:
            at = from0 + vec((target.x - from0.x) * k.float / 10, (target.y - from0.y) * k.float / 10)
            choice = picker.pick(at)
            frame(if choice.ok: choice.state else: state, at, key)
          for k in 0 .. 2: frame(if choice.ok: choice.state else: state, at, key)
        if choice.ok: state = choice.state
        for k in 0 .. 9: frame(state, at, "")
    else:
      for k in 0 .. 9: frame(state, vec(-100, -100), "")
    let endGrid = state.sdGrid
    if s.finish.len > 0 and s.finish.len != 36: problems.add "the end board needs 36 cells, it has " & $s.finish.len
    elif s.finish.len == 36 and endGrid != s.finish:
      problems.add "end board differs. Expected:\n" & sdShow(s.finish) & "    got:\n" & sdShow(endGrid)
    for o in s.outlines:
      var found = false
      for clue in puz.clues:
        if clue.word == o.word:
          found = true
          let got = state.grid.trace(clue).mapIt(sdCellName(it))
          if got != o.cells:
            problems.add "outline " & o.word & ": expected " & o.cells.join(" ") & ", got " & got.join(" ")
      if not found: problems.add "no word " & o.word & " in this puzzle"
    var verdict = "pass"
    if problems.len > 0:
      verdict = if s.change.len > 0: "todo" else: "fail"
    elif s.change.len > 0: verdict = "done"
    case verdict
    of "fail": inc failed
    of "todo": inc pend
    of "done": inc fixed
    else: discard
    let mark = case verdict
      of "pass": "ok  "
      of "todo": "todo"
      of "done": "done"
      else: "FAIL"
    echo mark, " ", s.path, ":", s.line, "  ", s.scenario
    if verdict in ["fail", "todo"]:
      for p in problems: echo "    ", p
    outFrames.add %*{"cap": s.cap, "line": s.line, "requirement": s.requirement, "scenario": s.scenario,
      "verdict": verdict, "problems": problems, "change": s.change, "path": s.path, "finish": s.finish, "letters": puz.letters, "gesture": s.gesture, "points": s.points,
      "tiles": tilesSvg, "boards": boards, "frames": frames}
  writeFile(paramStr(3), $(%*{"strings": sdStrings, "scenarios": outFrames}))
  echo scen.len, " drag scenarios. Specs: ", scen.len - failed - pend - fixed, " pass, ", failed, " fail. ",
    "Open changes: ", fixed, " done, ", pend, " still to do"
  if failed > 0: quit 1
