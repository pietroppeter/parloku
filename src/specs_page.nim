## The living spec page, `specs/index.html`: every OpenSpec spec and open change of Parloku, with its drag scenarios
## played on the game's own drawing and checked against the game's code while the page builds (tools/specdrag.nim).
## A living page, not a dated post: rebuild it whenever openspec/ or the game changes.
import std/[json, os, strutils]
import nimib
import style
import ../tools/specview

let root = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = root / "specs" / "index.html"
nb.doc.context["title"] = %"Parloku specs"
nb.doc.context["stylesheet"] = %(pageStyle & viewCss)
nb.doc.context["highlight"] = %""
nb.doc.context["disableHighlightJs"] = %true
func pageHeader(blk: JsonNode, nb: Nb): string =
  """<header><span><a href="../">parloku</a> · specs</span><span>living page</span></header>"""
nb.backend.partials["header"] = pageHeader

let (frames, run) = runScenarios(root, getEnv("PARLOKU_GAME", "src/parloku.nim"))   # another game source, for previews
let report = loadReport(root, frames)

nbRawHtml: svgDefs & """<script>document.body.dataset.skin = localStorage.getItem('parloku:look') || 'niki'</script>
<h1>Specs</h1>
<p class="lede">How Parloku behaves, written down. Every drag scenario below is played on the game's own code while
this page is built, and the animation shows what really happened.</p>""" & summary(report)

nbText: """
Parloku plans its work with [OpenSpec](https://github.com/Fission-AI/OpenSpec). A **spec** in `openspec/specs/` says
how one part of Parloku behaves today: requirements, each with scenarios (WHEN this, THEN that). A **change** in
`openspec/changes/` proposes new behaviour: why, what, the spec deltas, and tasks. When it ships it is archived and its
deltas join the specs. Tap a spec to open it; tap an animation to pause it.
"""

nbRawHtml: renderSpecs(report)
nbRawHtml: "<h2>Open changes</h2>" & renderChanges(report)
nbRawHtml: "<details class=\"spoiler\"><summary>the scenario run, as printed by tools/specdrag.nim</summary><pre>" &
  run.multiReplace(("&", "&amp;"), ("<", "&lt;")) & "</pre></details>" & playerJs(report)
nbSave
