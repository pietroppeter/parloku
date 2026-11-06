## Builds every page in one program: one compile and one link instead of one per page
## (about 20 s cold, 3 s with a warm nimcache, against about 2 minutes page by page).
##
##   nim c -r -d:release src/all.nim       # the whole site
##   nim c -r -d:release src/parloku.nim   # one page, as before
##
## A page is any src/*.nim that calls nbInit, found at compile time: a new page or
## devlog post needs no list here. Each page renders when its module is initialised,
## in import order: the game (parloku.nim) first, because other pages read the built
## index.html, then the rest by file name.

import std/[macros, os, strutils, algorithm]

const first = "parloku"

macro importPages(): untyped =
  let dir = currentSourcePath().parentDir
  var pages: seq[string]
  for kind, path in walkDir(dir):
    let (_, name, ext) = path.splitFile
    if kind == pcFile and ext == ".nim" and name notin ["all", first] and
        "\nnbInit" in "\n" & readFile(path):
      pages.add name
  pages.sort
  var src = ""
  # absolute paths: parseStmt has no file to be relative to
  for p in @[first] & pages: src.add "import \"" & dir / p & "\"\n"
  result = parseStmt(src)

{.warning[UnusedImport]: off.}
importPages()
