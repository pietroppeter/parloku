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
##   grab: refused                  # nothing may be picked up there
##   ```
## Waypoints are cells (`r2c6`), a letter's tile below the board (`below A`), a note (`note A r2c6`, a small
## letter written in a cell) or `off`; `double-tap: r3c6` taps a cell twice.
##
## Notes (small letters): `small: on` starts with the letters small, `notes: r1c1 AI, r2c2-r2c3 I` writes notes on
## the start board (`r2c2-r2c3`: on the edge between two cells, also a waypoint); `end small: on|off` and `end notes: r1c1 AI` (or `none`) check them after the gesture.
## The waypoint `space` is the empty spot between the letters below the board (`double-tap: space` switches size).
##
## This tool collects the scenarios; `tools/specdrag.js` plays them on the built page (`index.html`, so build
## `src/parloku.nim` first) in headless Chromium on an iPhone 13, with real pointer events, the way
## `tests/gestures/` does. The start board is handed to the page as saved progress, and the end board and the word
## outlines are read back from what the page draws. So a scenario checks what a player gets, whatever code does it.
##
## Usage:
##   nim r tools/specdrag.nim [--page:index.html] [--json:out.json] [capability or change ...]
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
    small*: bool                  ## `small: on`: the letters start small (notes)
    notes*, endNotes*: string     ## `notes:` on the start board, `end notes:` after ("" not checked, "none" none)
    endSmall*: string             ## `end small:` "on", "off" or "" (not checked)

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
    elif content.startsWith("double-tap:"):
      result.gesture = "double-tap"
      result.points = @[content[11 .. ^1].strip]
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
    elif content.startsWith("small:"): result.small = content[6 .. ^1].strip == "on"
    elif content.startsWith("end small:"): result.endSmall = content[10 .. ^1].strip
    elif content.startsWith("notes:"): result.notes = content[6 .. ^1].strip
    elif content.startsWith("end notes:"): result.endNotes = content[10 .. ^1].strip
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

when isMainModule:
  var page = "index.html"
  var jsonOut = ""
  var only: seq[string]
  for kind, key, val in getopt():
    case kind
    of cmdLongOption, cmdShortOption:
      if key == "page": page = val
      elif key == "json": jsonOut = val
    of cmdArgument: only.add key
    else: discard
  let root = getCurrentDir()
  let scen = collect(root, only)
  let work = getTempDir() / "parloku-specdrag"
  createDir work
  let input = work / "scenarios.json"
  writeFile(input, $(%scen))
  if jsonOut.len == 0: jsonOut = work / "frames.json"
  let rc = execCmd("node " & quoteShell(root / "tools" / "specdrag.js") & " " & quoteShell(input) & " " &
    quoteShell(jsonOut) & " " & quoteShell(if page.isAbsolute: page else: root / page))
  quit(rc)
