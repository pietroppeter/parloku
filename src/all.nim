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

# Every page counts a visit (way-of-working spec): each generated page must carry the Plausible snippet.
from style import analytics
block:
  let root = currentSourcePath().parentDir.parentDir
  var pages = @["index.html", "builder.html", "builder-howto.html", "istruzioni.html", "spiega.html"]
  for d in ["devlog", "garden", "specs"]:
    if fileExists(root / d / "index.html"): pages.add d / "index.html"
    for kind, sub in walkDir(root / d):
      if kind == pcDir and fileExists(sub / "index.html"): pages.add sub.relativePath(root) / "index.html"
  var missing: seq[string]
  for p in pages:
    if fileExists(root / p) and analytics notin readFile(root / p): missing.add p
  if missing.len > 0:
    quit "these pages lack the Plausible snippet (style.analytics): " & missing.join(", ")
  echo "analytics on ", pages.len, " pages"
