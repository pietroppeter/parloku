## specdrag: run the drag scenarios in the OpenSpec specs against the game's own code.
##
## A drag scenario is a ```drag block inside a `#### Scenario:` of `openspec/specs/*/spec.md`:
##
##   ```drag
##   puzzle: 2                      # data/puzzle2-*.json, or a ?p= code
##   start:                         # the board before the gesture, '.' for an empty cell
##     . . . . . M
##     ...
##   drag: r5c6 -> r4c5             # or hold: (long press first), or none (just look)
##   end:                           # the board after release
##     ...
##   outline MAGIA: r1c6 r2c6 r3c6 r4c6 r4c5   # cells the word's outline covers
##   grab: refused                  # instead of end: nothing may be picked up there
##   ```
##
## Waypoints are cells (`r2c6`), a letter's stack below the board (`stack A`) or `off` (far from every cell).
##
## The game is a nimib notebook, so its code is not a module. This tool takes the blocks of `src/parloku.nim`
## that run both natively and in the browser (`nbCodeAnd(nbJsFromCode)`), plus the stage's grab redirect from the
## browser wiring, writes them with a small harness into one program, compiles it natively and runs it.
## The harness drives a drag the way the browser stage does: redirect the grab, ask `tileSpec` for a behaviour,
## call `pick` along the pointer path, commit the last pick on release.
##
## Usage:
##   nim r tools/specdrag.nim [--game:src/parloku.nim] [--json:out.json] [capability ...]
##
## With `--json` it also writes every frame of every drag (tile positions, outlines) for the spec viewer
## (tools/specview.nim), which plays them as small animations.
##
## Scenarios in the main specs (`openspec/specs/`) describe the game as it is: they must pass, and exit code 1
## says one doesn't. Scenarios in an open change (`openspec/changes/<name>/specs/`) describe what the change will
## do, so they may fail ("todo") until it is built.

import std/[os, osproc, strutils, parseopt, json, algorithm]

type
  Outline* = object
    word*: string
    cells*: seq[string]

  DragScenario* = object
    cap*, requirement*, scenario*: string
    change*: string               ## "" for a main spec (must pass), else the open change it belongs to (may fail)
    path*: string                 ## the spec file, relative to the repository
    line*: int
    puzzle*, gesture*: string     ## gesture: "drag", "hold" or "none"
    points*: seq[string]
    start*, finish*: string       ## 36 chars each ('.' empty); finish "" when not given
    outlines*: seq[Outline]
    refused*: bool                ## `grab: refused`: nothing may be picked up at the first waypoint

proc gridOf(rows: seq[string]): string =
  for r in rows:
    for ch in r:
      if ch notin {' ', '\t'}: result.add ch

proc parseDragBlock*(body: seq[string]): DragScenario =
  var i = 0
  proc readGrid(): string =
    var rows: seq[string]
    while i + 1 < body.len and body[i + 1].startsWith(" ") and rows.len < 6:
      inc i
      rows.add body[i].strip
    gridOf(rows)
  result.gesture = "none"
  while i < body.len:
    let l = body[i].strip
    let content = l.split('#')[0].strip
    if content.startsWith("puzzle:"): result.puzzle = content[7 .. ^1].strip
    elif content == "start:": result.start = readGrid()
    elif content == "end:": result.finish = readGrid()
    elif content.startsWith("drag:") or content.startsWith("hold:"):
      if content[5 .. ^1].strip == "none":
        inc i
        continue
      result.gesture = content[0 .. 3]
      for p in content[5 .. ^1].replace("→", "->").split("->"): result.points.add p.strip
    elif content.startsWith("outline "):
      let parts = content[8 .. ^1].split(':', maxsplit = 1)
      result.outlines.add Outline(word: parts[0].strip, cells: parts[1].splitWhitespace)
    elif content == "grab: refused": result.refused = true
    inc i

proc collectFile(path, cap, change, rel: string): seq[DragScenario] =
  let lines = readFile(path).splitLines
  var req, scen: string
  var i = 0
  while i < lines.len:
    let l = lines[i]
    if l.startsWith("### Requirement:"): req = l[16 .. ^1].strip
    elif l.startsWith("#### Scenario:"): scen = l[14 .. ^1].strip
    elif l.strip == "```drag":
      var body: seq[string]
      let at = i + 1
      inc i
      while i < lines.len and lines[i].strip != "```":
        body.add lines[i]; inc i
      var s = parseDragBlock(body)
      (s.cap, s.requirement, s.scenario, s.line, s.change, s.path) = (cap, req, scen, at, change, rel)
      result.add s
    inc i

proc capsIn(dir: string): seq[string] =
  for kind, path in walkDir(dir):
    if kind == pcDir and fileExists(path / "spec.md"): result.add path.lastPathPart
  result.sort

proc collect*(root: string, only: seq[string] = @[]): seq[DragScenario] =
  ## every drag scenario: the main specs first, then the open changes' spec deltas (not the archived ones)
  let specs = root / "openspec" / "specs"
  for cap in capsIn(specs):
    if only.len == 0 or cap in only:
      result.add collectFile(specs / cap / "spec.md", cap, "", "openspec/specs/" & cap & "/spec.md")
  var changes: seq[string]
  for kind, path in walkDir(root / "openspec" / "changes"):
    if kind == pcDir and path.lastPathPart != "archive": changes.add path.lastPathPart
  changes.sort
  for ch in changes:
    let dir = root / "openspec" / "changes" / ch / "specs"
    for cap in capsIn(dir):
      if only.len == 0 or cap in only or ch in only:
        result.add collectFile(dir / cap / "spec.md", cap, ch, "openspec/changes/" & ch & "/specs/" & cap & "/spec.md")

proc gameCode*(gameSrc: string): string =
  ## the shared (native + browser) blocks of the notebook, then its grab redirect as `grabKey`
  let lines = readFile(gameSrc).splitLines
  var i = 0
  while i < lines.len:
    if lines[i].startsWith("nbCodeAnd(nbJsFromCode):"):
      inc i
      while i < lines.len and (lines[i].len == 0 or lines[i].startsWith("  ")):
        result.add (if lines[i].len >= 2: lines[i][2 .. ^1] else: "") & "\n"
        inc i
    else: inc i
  const head = "stage.redirect = proc (b: Board, key: string): string ="
  for k, l in lines:
    if l.strip == head:
      let ind = l.len - l.strip(trailing = false).len
      result.add "\nproc grabKey(b: Board, key: string): string =\n"
      var j = k + 1
      while j < lines.len and (lines[j].strip.len == 0 or lines[j].len - lines[j].strip(trailing = false).len > ind):
        if lines[j].strip.len > 0: result.add "  " & lines[j][ind + 2 .. ^1] & "\n"
        inc j
      return
  result.add "\nproc grabKey(b: Board, key: string): string = key\n"

const harness = staticRead("specdrag_harness.nim")

when isMainModule:
  var game = "src/parloku.nim"
  var jsonOut = ""
  var only: seq[string]
  for kind, key, val in getopt():
    case kind
    of cmdLongOption, cmdShortOption:
      if key == "game": game = val
      elif key == "json": jsonOut = val
    of cmdArgument: only.add key
    else: discard
  let root = getCurrentDir()
  let scen = collect(root, only)
  let work = getTempDir() / "parloku-specdrag"
  createDir work
  let input = work / "scenarios.json"
  writeFile(input, $(%scen))
  let prog = work / "specdrag_run.nim"
  writeFile(prog, "import std/[json, os, algorithm, tables]\n" & gameCode(if game.isAbsolute: game else: root / game) & "\n" & harness)
  let (outp, code) = execCmdEx("nim c -d:release --hints:off --warnings:off --verbosity:0 -o:" &
    quoteShell(work / "specdrag_run") & " " & quoteShell(prog))
  if code != 0:
    echo outp
    quit "specdrag: the game code did not compile natively (generated program: " & prog & ")", 2
  let dataDir = root / "data"
  let (res, rc) = execCmdEx(quoteShell(work / "specdrag_run") & " " & quoteShell(input) & " " &
    quoteShell(dataDir) & " " & quoteShell(if jsonOut.len > 0: jsonOut else: work / "frames.json"))
  stdout.write res
  quit(rc)
