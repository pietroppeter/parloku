## The living spec page, `specs/index.html`: every OpenSpec spec and open change of Parloku, with its drag scenarios
## played on the game's own drawing and checked against the game's code while the page builds (tools/specdrag.nim).
## A living page, not a dated post: rebuild it whenever openspec/ or the game changes.
## `?change=<names>` and `?spec=<names>` (or the same after `#`) show only those changes and specs: see "Links to a
## part of this page" below, and AGENTS.md.
import std/[json, os, strutils]
import nimib
import style
import ../tools/specview
import markdown

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

const filterCss = """<style>
.filterbar{background:var(--card);border:1.5px solid var(--line);border-radius:14px;padding:8px 14px;margin:10px 0;font-size:15px;line-height:1.45}
.filterbar a{white-space:nowrap}
details.links{background:var(--card);border:1.5px solid var(--line);border-radius:14px;padding:6px 14px;margin:10px 0;font-size:15px}
details.links summary{cursor:pointer;font-weight:700}
details.links code{font:13px "JetBrains Mono",monospace;background:var(--soft);padding:1px 4px;border-radius:5px}
</style>"""

let (frames, run) = runScenarios(root, getEnv("PARLOKU_PAGE", "index.html"))   # build src/parloku.nim first
let report = loadReport(root, frames)

nbRawHtml: svgDefs & """<script>document.body.dataset.skin = localStorage.getItem('parloku:look') || 'niki'</script>
<h1>Specs</h1>
<div class="filterbar" id="filterbar" hidden></div>
<p class="lede">How Parloku behaves, written down. Every drag scenario below is played on the game's own code while
this page is built, and the animation shows what really happened.</p>""" & summary(report)

nbRawHtml: """<section class="about">""" & markdown("""
Parloku plans its work with [OpenSpec](https://github.com/Fission-AI/OpenSpec). A **spec** in `openspec/specs/` says
how one part of Parloku behaves today: requirements, each with scenarios (WHEN this, THEN that). A **change** in
`openspec/changes/` proposes new behaviour: why, what, the spec deltas, and tasks. When it ships it is archived and its
deltas join the specs. Tap a spec to open it; tap an animation to pause it.
""") & "</section>"

nbRawHtml: """<details class="links" id="links"><summary>Links to a part of this page, for people and agents</summary>""" &
  markdown("""
Add `change=` or `spec=` to this page's link to show only some of it, opened:

- [`specs/?change=keep-one-look`](?change=keep-one-look): one open change, and nothing else
- [`specs/?change=keep-one-look,share-a-game`](?change=keep-one-look,share-a-game): two changes (or `?change=keep-one-look&change=share-a-game`)
- [`specs/?change=keep-one-look&spec=theming`](?change=keep-one-look&spec=theming): a change and the spec it touches
- [`specs/?spec=word-*`](?spec=word-*): the specs whose names start with `word-`
- [`specs/?change=all`](?change=all): every open change, no specs

The names are the folder names in `openspec/specs/` and `openspec/changes/`, the bold name on each card. The same
parameters work after `#` (`specs/#change=keep-one-look`) where a link loses its query string. A name that is not found
is named at the top. With no parameter the page shows everything.

**For agents.** The filter runs in the browser: open the link in a real browser (Playwright, say) and the page shows only
what it names. A tool that fetches the page without running JavaScript gets the whole page, animation frames included.
To read one spec or change, read its markdown instead, in a checkout or from GitHub:

- a spec: `openspec/specs/<name>/spec.md`
- a change: `openspec/changes/<name>/proposal.md`, `tasks.md` and `specs/<spec>/spec.md` (its deltas)
- on GitHub: `https://raw.githubusercontent.com/pietroppeter/parloku/main/openspec/changes/<name>/proposal.md`; an open
  change may be only on its branch, so put the branch name in place of `main`
""") & "</details>"

nbRawHtml: renderSpecs(report)
nbRawHtml: """<h2 id="open-changes">Open changes</h2>""" & renderChanges(report)
nbRawHtml: "<details class=\"spoiler\"><summary>the scenario run, as printed by tools/specdrag.nim</summary><pre>" &
  run.multiReplace(("&", "&amp;"), ("<", "&lt;")) & "</pre></details>" & playerJs(report) & filterCss

# The filter: `?change=a,b&spec=c` (or the same after `#`) shows only those changes and specs. Runs in the browser.
nbJsFromCode:
  import std/[dom, strutils]

  proc search(): cstring {.importjs: "(location.search)@".}
  proc hash(): cstring {.importjs: "(location.hash)@".}
  proc pathname(): cstring {.importjs: "(location.pathname)@".}
  proc decodeUri(s: cstring): cstring {.importjs: "decodeURIComponent(#)".}
  proc nextEl(e: Element): Element {.importjs: "#.nextElementSibling".}
  proc closestA(ev: Event): Element {.importjs: "#.target.closest('a')".}
  proc hrefOf(e: Element): cstring {.importjs: "(#.getAttribute('href') || '')".}

  type Pick = object
    named, all: bool
    names: seq[string]
    found: seq[bool]

  proc htmlEsc(s: string): string = s.multiReplace(("&", "&amp;"), ("<", "&lt;"), (">", "&gt;"))

  proc addNames(p: var Pick, value: string) =
    p.named = true
    for n in value.split(','):
      let n = n.strip.toLowerAscii
      if n.len == 0: continue
      if n == "all": p.all = true
      elif n notin p.names: (p.names.add n; p.found.add false)

  proc readPicks(): (Pick, Pick) =
    ## the `change` and `spec` parameters of the query string and of the hash, as lists of names
    var change, spec: Pick
    var query = $search()
    let h = $hash()
    if '=' in h: query.add "&" & h.strip(leading = true, trailing = false, chars = {'#', '?'})
    for part in query.strip(chars = {'?'}).split('&'):
      let eq = part.find('=')
      if eq < 0: continue
      let key = part[0 ..< eq]
      if key notin ["change", "spec"]: continue
      let value = $decodeUri(part[eq + 1 .. ^1].replace("+", " ").cstring)
      if key == "change": change.addNames(value) else: spec.addNames(value)
    (change, spec)

  proc pick(p: var Pick, name: string): bool =
    if p.all: return true
    for i, n in p.names:
      if n == name or (n.endsWith("*") and name.startsWith(n[0 .. ^2])):
        p.found[i] = true
        result = true

  proc show(e: Element, yes: bool) =
    if yes: e.removeAttribute("hidden") else: e.setAttribute("hidden", "")

  proc tidyHeads() =
    ## a family heading shows when one of its specs does; "Open changes" when one change does
    for h in document.querySelectorAll(".specview h3.fam"):
      var any = false
      var e = h.nextEl
      while e != nil and e.nodeName != "H3":
        if e.nodeName == "DETAILS" and not e.hasAttribute("hidden"): any = true
        e = e.nextEl
      h.show(any)
    var anyChange = false
    for d in document.querySelectorAll("details.change"):
      if not d.hasAttribute("hidden"): anyChange = true
    let oc = document.getElementById("open-changes")
    if oc != nil: oc.show(anyChange)

  proc describe(p: Pick, kind, kinds: string): string =
    if not p.named: return ""
    if p.all: return "all the " & kinds
    var shown: seq[string]
    for i, n in p.names:
      if p.found[i]: shown.add "<b>" & htmlEsc(n) & "</b>"
    if shown.len == 0: return ""
    let label = if shown.len == 1: kind else: kinds
    "the " & label & " " & shown.join(", ")

  proc applyFilter() =
    var (change, spec) = readPicks()
    let filtered = change.named or spec.named
    let bar = document.getElementById("filterbar")
    for e in document.querySelectorAll(".lede, .stats, .about, details.links, details.spoiler"): e.show(not filtered)
    for d in document.querySelectorAll("details.spec"):
      let yes = not filtered or spec.pick(($d.id)[5 .. ^1])
      d.show(yes)
      if filtered and yes and not spec.all: d.setAttribute("open", "")
    for d in document.querySelectorAll("details.change"):
      let yes = not filtered or change.pick(($d.id)[7 .. ^1])
      d.show(yes)
      if filtered and yes and not change.all: d.setAttribute("open", "")
    tidyHeads()
    if not filtered:
      bar.show(false)
      return
    var parts: seq[string]
    for s in [change.describe("open change", "open changes"), spec.describe("spec", "specs")]:
      if s.len > 0: parts.add s
    var missing: seq[string]
    for (p, kind) in [(change, "change"), (spec, "spec")]:
      for i, n in p.names:
        if not p.found[i]: missing.add "<b>" & htmlEsc(n) & "</b> (" & kind & ")"
    let showing = if change.all or spec.all: "Showing " else: "Showing only "
    var html = if parts.len > 0: showing & parts.join(" and ") & "." else: "Nothing to show."
    if missing.len > 0: html.add " Not found: " & missing.join(", ") & "."
    html.add " <a href=\"" & $pathname() & "\">Show everything</a> · <a href=\"" & $pathname() & "#links\">how these links work</a>"
    bar.innerHTML = html.cstring
    bar.show(true)

  proc reveal(id: string) =
    ## a link to a spec or change that the filter hides shows it
    let t = document.getElementById(id.cstring)
    if t == nil or not t.hasAttribute("hidden"): return
    t.show(true)
    t.setAttribute("open", "")
    tidyHeads()

  applyFilter()
  block:   # a link to one card (#spec-builder, #links) opens it
    let h = $hash()
    if h.len > 1 and '=' notin h:
      let t = document.getElementById(h[1 .. ^1].cstring)
      if t != nil and t.nodeName == "DETAILS": t.setAttribute("open", "")
  document.addEventListener("click", proc (ev: Event) =
    let a = ev.closestA
    if a != nil:
      let href = $a.hrefOf
      if href.startsWith("#spec-") or href.startsWith("#change-"): reveal(href[1 .. ^1]))
  window.addEventListener("hashchange", proc (ev: Event) =
    let h = $hash()
    if '=' in h: applyFilter()
    elif h.len > 1: reveal(h[1 .. ^1]))
nbSave
