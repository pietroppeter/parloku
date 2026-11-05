## specview: the OpenSpec specs and changes of Parloku as one HTML fragment, in the game's own look.
##
## Reads `openspec/specs/*/spec.md` and the open changes in `openspec/changes/` (proposal, tasks, spec deltas),
## and the frames `tools/specdrag.nim --json` recorded, and renders:
## - a summary (specs, requirements, scenarios, drag scenarios and how many pass),
## - every spec, grouped by family, with its requirements and WHEN/THEN scenarios,
## - every ```drag scenario as a small animation of the real game drawing (tiles, outlines, the finger), played from
##   the recorded frames, with its result on the build: passes, fails, or still to do in an open change,
## - every open change: its proposal, its tasks and its spec deltas.
##
## Used by `src/specs_page.nim` (the living page, `specs/index.html`) and `src/devlog_openspec.nim` (the post).

import std/[os, osproc, strutils, json, algorithm, sequtils, strformat]
import markdown

type
  Scen* = object
    name*: string
    bullets*: seq[string]
    drag*: int              ## index in the frames' scenarios, -1 when the scenario has no ```drag block
  Req* = object
    name*, body*: string
    scens*: seq[Scen]
  Section* = object
    title*: string          ## "Requirements", "ADDED Requirements", "MODIFIED Requirements", ...
    reqs*: seq[Req]
  Spec* = object
    cap*, purpose*: string
    sections*: seq[Section]
  Change* = object
    name*, proposal*, tasks*: string
    done*, total*: int
    deltas*: seq[Spec]
  Report* = object
    specs*: seq[Spec]
    changes*: seq[Change]
    frames*: JsonNode

const families* = [
  ("The puzzle", @["game-rules", "puzzle-format"]),
  ("Playing", @["tiles-and-dragging", "word-snakes", "player", "logical-path"]),
  ("Looking", @["first-principles", "play-screen", "theming"]),
  ("Making", @["solver", "builder"]),
  ("Working", @["way-of-working"])]

proc esc(s: string): string = s.multiReplace(("&", "&amp;"), ("<", "&lt;"), (">", "&gt;"), ("\"", "&quot;"))
proc md(s: string): string = markdown(s.strip)

proc parseSpec(path, cap, rel: string, frames: JsonNode): Spec =
  result.cap = cap
  let lines = readFile(path).splitLines
  var inPurpose = false
  var purpose, body: seq[string]
  var i = 0
  template curReq: untyped = result.sections[^1].reqs[^1]
  proc dragIndex(line: int): int =
    for k, s in frames["scenarios"].getElems:
      if s["path"].getStr == rel and s["line"].getInt == line: return k
    -1
  while i < lines.len:
    let l = lines[i]
    if l.startsWith("## Purpose"): inPurpose = true
    elif l.startsWith("## "):
      inPurpose = false
      result.sections.add Section(title: l[3 .. ^1].strip)
    elif l.startsWith("### Requirement:"):
      if result.sections.len == 0: result.sections.add Section(title: "Requirements")
      result.sections[^1].reqs.add Req(name: l[16 .. ^1].strip)
    elif l.startsWith("#### Scenario:"):
      curReq.scens.add Scen(name: l[14 .. ^1].strip, drag: -1)
    elif l.strip == "```drag":
      let at = i + 1
      while i + 1 < lines.len and lines[i + 1].strip != "```": inc i
      inc i
      if result.sections.len > 0 and curReq.scens.len > 0: curReq.scens[^1].drag = dragIndex(at)
    elif inPurpose: purpose.add l
    elif result.sections.len > 0 and result.sections[^1].reqs.len > 0:
      if curReq.scens.len > 0:
        if l.strip.startsWith("- "): curReq.scens[^1].bullets.add l.strip[2 .. ^1]
        elif l.strip.len > 0 and curReq.scens[^1].bullets.len > 0: curReq.scens[^1].bullets[^1].add " " & l.strip
      else:
        curReq.body.add l & "\n"
    inc i
  result.purpose = purpose.join("\n").strip

proc loadReport*(root: string, frames: JsonNode): Report =
  result.frames = frames
  let specs = root / "openspec" / "specs"
  var caps: seq[string]
  for kind, path in walkDir(specs):
    if kind == pcDir and fileExists(path / "spec.md"): caps.add path.lastPathPart
  caps.sort
  for cap in caps:
    result.specs.add parseSpec(specs / cap / "spec.md", cap, "openspec/specs/" & cap & "/spec.md", frames)
  var names: seq[string]
  for kind, path in walkDir(root / "openspec" / "changes"):
    if kind == pcDir and path.lastPathPart != "archive": names.add path.lastPathPart
  names.sort
  for n in names:
    let dir = root / "openspec" / "changes" / n
    var ch = Change(name: n)
    if fileExists(dir / "proposal.md"): ch.proposal = readFile(dir / "proposal.md")
    if fileExists(dir / "tasks.md"):
      ch.tasks = readFile(dir / "tasks.md")
      for l in ch.tasks.splitLines:
        if l.strip.startsWith("- [x]"): (inc ch.done; inc ch.total)
        elif l.strip.startsWith("- [ ]"): inc ch.total
    if dirExists(dir / "specs"):
      for kind, path in walkDir(dir / "specs"):
        if kind == pcDir and fileExists(path / "spec.md"):
          let cap = path.lastPathPart
          ch.deltas.add parseSpec(path / "spec.md", cap, "openspec/changes/" & n & "/specs/" & cap & "/spec.md", frames)
    result.changes.add ch

# ---------------------------------------------------------------------------- rendering

proc verdictOf*(r: Report, k: int): string = r.frames["scenarios"][k]["verdict"].getStr

proc miniGrid(g: string, letters: string): string =
  ## the expected end board, as a small grid of letters
  result = """<div class="endgrid">"""
  for c in 0 ..< 36:
    let ch = if c < g.len: g[c] else: '.'
    let li = letters.find(ch)
    let box = if ((c div 6) div 2 + (c mod 6) div 3) mod 2 == 0: "ca" else: "cb"
    if li >= 0: result.add &"""<span class="{box}"><span class="lt g{li} i{li}">{ch}</span></span>"""
    else: result.add &"""<span class="{box}"></span>"""
  result.add "</div>"

proc dragFigure*(r: Report, k: int): string =
  let s = r.frames["scenarios"][k]
  let v = s["verdict"].getStr
  let gesture = if s["gesture"].getStr == "none": "just look"
    else: s["gesture"].getStr & " " & s["points"].getElems.mapIt(it.getStr).join(" → ")
  let (badge, note) = case v
    of "pass": ("✓ passes", "The game does this today.")
    of "done": ("✓ done", "The game already does this: the change can be archived.")
    of "todo": ("◌ to do", "The animation shows what the game does today, not yet what the change wants.")
    else: ("✗ fails", "The game does not do this yet.")
  result = &"""<figure class="drag v-{v}" data-k="{k}"><div class="play"><svg viewBox="50 0 500 664" aria-label="animation: {esc(gesture)}">""" &
    """<g class="bg"></g><g class="fg"></g><g class="overlay"></g><circle class="finger" r="24" cx="-100" cy="-100"/></svg>""" &
    """<button class="replay" aria-label="replay">↻</button></div>""" &
    &"""<figcaption><span class="badge">{badge}</span> <code>{esc(gesture)}</code><p>{note}</p>"""
  for p in s["problems"].getElems:
    if not p.getStr.startsWith("end board"): result.add &"""<p class="why">{esc(p.getStr)}</p>"""
  if v in ["todo", "fail"] and s["finish"].getStr.len == 36:
    result.add """<p class="want">It should end like this:</p>""" & miniGrid(s["finish"].getStr, s["letters"].getStr)
  result.add "</figcaption></figure>"

proc scenHtml(r: Report, sc: Scen): string =
  result = &"""<div class="scen"><h5>{esc(sc.name)}</h5><ul>"""
  for b in sc.bullets: result.add "<li>" & md(b).replace("<p>", "").replace("</p>", "") & "</li>"
  result.add "</ul>"
  if sc.drag >= 0: result.add dragFigure(r, sc.drag)
  result.add "</div>"

proc reqHtml(r: Report, q: Req, tag = ""): string =
  let t = if tag.len > 0: &"""<span class="tag t-{tag.toLowerAscii}">{tag}</span> """ else: ""
  result = &"""<article class="req"><h4>{t}{esc(q.name)}</h4>{md(q.body)}"""
  for sc in q.scens: result.add scenHtml(r, sc)
  result.add "</article>"

proc counts(sp: Spec, r: Report): (int, int, int, int) =
  ## requirements, scenarios, drag scenarios, drag scenarios passing
  for sec in sp.sections:
    for q in sec.reqs:
      inc result[0]
      for sc in q.scens:
        inc result[1]
        if sc.drag >= 0:
          inc result[2]
          if r.verdictOf(sc.drag) in ["pass", "done"]: inc result[3]

proc specHtml(r: Report, sp: Spec, n: int): string =
  let (nr, ns, nd, np) = sp.counts(r)
  let dots = if nd > 0: &""" · <span class="ok">{np}/{nd} ▶</span>""" else: ""
  result = &"""<details class="spec" id="spec-{sp.cap}"><summary><span class="sn g{n mod 6} i{n mod 6}">{n + 1}</span>""" &
    &"""<span class="nm">{sp.cap}</span><span class="ct">{nr} req · {ns} scen{dots}</span>""" &
    &"""<span class="pp">{esc(sp.purpose)}</span></summary>"""
  for sec in sp.sections:
    for q in sec.reqs: result.add reqHtml(r, q)
  result.add "</details>"

proc changeHtml(r: Report, ch: Change): string =
  var why = ch.proposal
  let pct = if ch.total > 0: ch.done * 100 div ch.total else: 0
  result = &"""<details class="change" id="change-{ch.name}"><summary><span class="nm">{ch.name}</span>""" &
    &"""<span class="ct">{ch.done}/{ch.total} tasks</span><span class="bar"><i style="width:{pct}%"></i></span></summary>"""
  result.add """<div class="cbody"><h4>Proposal</h4>""" & md(why)
  if ch.tasks.len > 0:
    result.add "<h4>Tasks</h4>" & md(ch.tasks).replace("[ ]", "☐").replace("[x]", "☑")
  for d in ch.deltas:
    result.add &"""<h4>Spec delta: <a href="#spec-{d.cap}">{d.cap}</a></h4>"""
    for sec in d.sections:
      let tag = sec.title.split(' ')[0]
      for q in sec.reqs: result.add reqHtml(r, q, tag)
  result.add "</div></details>"

proc summary*(r: Report): string =
  var nr, ns, nd, np: int
  for sp in r.specs:
    let (a, b, c, d) = sp.counts(r)
    nr += a; ns += b; nd += c; np += d
  var todo = 0
  for s in r.frames["scenarios"].getElems:
    if s["verdict"].getStr == "todo": inc todo
  &"""<div class="stats"><span><b>{r.specs.len}</b> specs</span><span><b>{nr}</b> requirements</span>""" &
    &"""<span><b>{ns}</b> scenarios</span><span><b>{np}/{nd}</b> drag scenarios pass</span>""" &
    &"""<span><b>{r.changes.len}</b> open changes, <b>{todo}</b> scenarios to do</span></div>"""

proc renderSpecs*(r: Report): string =
  var n = 0
  var seen: seq[string]
  result = """<div class="specview">"""
  for (fam, caps) in families:
    var part = ""
    for cap in caps:
      for sp in r.specs:
        if sp.cap == cap:
          part.add specHtml(r, sp, n); inc n; seen.add cap
    if part.len > 0: result.add &"""<h3 class="fam">{fam}</h3>""" & part
  var rest = ""
  for sp in r.specs:
    if sp.cap notin seen: (rest.add specHtml(r, sp, n); inc n)
  if rest.len > 0: result.add """<h3 class="fam">Other</h3>""" & rest
  result.add "</div>"

proc renderChanges*(r: Report): string =
  result = """<div class="specview">"""
  for ch in r.changes: result.add changeHtml(r, ch)
  result.add "</div>"

const viewCss* = """<style>
.specview{margin:10px 0}
.specview .fam{font:700 13px "JetBrains Mono",monospace;letter-spacing:.12em;text-transform:uppercase;color:var(--muted);margin:26px 0 8px}
.specview details{background:var(--card);border:var(--border,1.5px) solid var(--line);border-radius:var(--radius,16px);margin:8px 0;overflow:hidden}
.specview summary{cursor:pointer;list-style:none;padding:10px 14px;display:grid;grid-template-columns:auto 1fr auto;gap:2px 10px;align-items:center}
.specview summary::-webkit-details-marker{display:none}
.specview .sn{grid-row:span 2;width:34px;height:34px;border-radius:50%;display:grid;place-items:center;font:800 16px var(--font-head);
  background:var(--g0);border:var(--tsw,0) solid var(--ink)}
.specview .sn.g0{background:var(--g0);color:var(--i0)} .specview .sn.g1{background:var(--g1);color:var(--i1)} .specview .sn.g2{background:var(--g2);color:var(--i2)}
.specview .sn.g3{background:var(--g3);color:var(--i3)} .specview .sn.g4{background:var(--g4);color:var(--i4)} .specview .sn.g5{background:var(--g5);color:var(--i5)}
.specview .nm{font:700 18px var(--font-head)}
.specview .ct{font:600 12px "JetBrains Mono",monospace;color:var(--muted);white-space:nowrap}
.specview .ct .ok{color:var(--w1,#2f7a4d)}
.specview .pp{grid-column:2 / 4;font:14.5px var(--font-body);line-height:1.4;color:var(--muted)}
.specview details[open] > summary{border-bottom:1.5px solid var(--line)}
.specview .req{padding:10px 14px 4px;border-bottom:1px dashed var(--line)}
.specview .req:last-child{border-bottom:0}
.specview .req h4{font:700 16.5px var(--font-head);margin:6px 0 4px}
.specview .req p{margin:4px 0;font-size:15.5px;line-height:1.5}
.specview code{font:13px "JetBrains Mono",monospace;background:var(--soft);padding:1px 4px;border-radius:5px}
.specview .scen{margin:8px 0 12px 0;padding:8px 12px;background:var(--soft);border-radius:12px}
.specview .scen h5{margin:0;font:700 14px var(--font-body)}
.specview .scen ul{margin:4px 0 0;padding-left:18px;font-size:14.5px;line-height:1.45}
.specview .tag{font:700 11px "JetBrains Mono",monospace;padding:2px 6px;border-radius:6px;vertical-align:2px}
.specview .t-added{background:#d7f0dd;color:#1d5b2c} .specview .t-modified{background:#fbefd0;color:#6d4c00} .specview .t-removed{background:#f6dcdc;color:#8a1f1f}
.specview figure.drag{margin:10px 0 2px;display:grid;grid-template-columns:minmax(0,190px) minmax(0,1fr);gap:12px;align-items:start}
@media (max-width:420px){.specview figure.drag{grid-template-columns:minmax(0,150px) minmax(0,1fr);gap:9px}}
.specview .play{position:relative;background:var(--card);border-radius:12px;border:1.5px solid var(--line)}
.specview .play svg{display:block;width:100%;height:auto;overflow:hidden;cursor:pointer}
.specview .replay{position:absolute;right:4px;bottom:4px;border:0;background:var(--card);color:var(--muted);border-radius:50%;width:28px;height:28px;font-size:16px;cursor:pointer}
.specview .finger{fill:rgba(0,0,0,.16);stroke:rgba(0,0,0,.35);stroke-width:2;pointer-events:none;transition:opacity .2s}
.specview figcaption{font-size:14px;line-height:1.4}
.specview figcaption p{margin:4px 0}
.specview .badge{display:inline-block;font:700 12px "JetBrains Mono",monospace;padding:2px 8px;border-radius:999px;margin-bottom:4px}
.specview .v-pass .badge,.specview .v-done .badge{background:#d7f0dd;color:#1d5b2c}
.specview .v-todo .badge{background:#fbefd0;color:#6d4c00}
.specview .v-fail .badge{background:#f6dcdc;color:#8a1f1f}
.specview .why{font-size:12.5px;line-height:1.35;color:var(--muted)}
.specview .change summary{grid-template-columns:1fr auto}
.specview .change .bar{grid-column:1 / 3;height:6px;border-radius:3px;background:var(--soft);overflow:hidden}
.specview .change .bar i{display:block;height:100%;background:var(--w1,#2f7a4d)}
.specview .cbody{padding:4px 14px 10px;font-size:15px}
.specview .cbody h4{font:700 15px var(--font-head);margin:14px 0 4px}
.specview .cbody h2{font:700 13px "JetBrains Mono",monospace;letter-spacing:.08em;text-transform:uppercase;color:var(--muted);margin:12px 0 2px}
.specview .cbody h3{font:700 14px var(--font-body);margin:8px 0 2px}
.specview .cbody ul{padding-left:20px;margin:4px 0}
.specview .cbody li{list-style:none;margin-left:-14px}
.specview .cbody .req{padding:6px 0}
.specview .endgrid{display:grid;grid-template-columns:repeat(6,1fr);gap:2px;width:150px;max-width:100%;margin:6px 0}
.specview .endgrid > span{aspect-ratio:1;border-radius:3px;display:flex;align-items:center;justify-content:center}
.specview .endgrid > .ca{background:var(--ca,#fff);box-shadow:inset 0 0 0 1px var(--line)} .specview .endgrid > .cb{background:var(--cb,#f3f1ea)}
.specview .endgrid .lt{width:86%;height:86%;border-radius:50%;display:flex;align-items:center;justify-content:center;font:800 11px var(--font-glyph);line-height:1}
.specview .endgrid .g0{background:var(--g0);color:var(--i0)} .specview .endgrid .g1{background:var(--g1);color:var(--i1)} .specview .endgrid .g2{background:var(--g2);color:var(--i2)}
.specview .endgrid .g3{background:var(--g3);color:var(--i3)} .specview .endgrid .g4{background:var(--g4);color:var(--i4)} .specview .endgrid .g5{background:var(--g5);color:var(--i5)}
.specview summary,.specview figcaption{font-family:var(--font-body);text-align:left;color:var(--ink);font-size:15px}
.specview .want{font-weight:700;margin-top:8px!important}
.stats{display:flex;flex-wrap:wrap;gap:6px;margin:12px 0}
.stats span{background:var(--card);border:1.5px solid var(--line);border-radius:999px;padding:3px 10px;font-size:13.5px}
</style>"""

proc playerJs*(r: Report): string =
  ## the frames as data and a tiny player: each figure builds its tiles once, then moves them frame by frame
  "<script id=\"specframes\" type=\"application/json\">" & ($r.frames).replace("</", "<\\/") & "</script>" & """
<script>
(() => {
  const data = JSON.parse(document.getElementById('specframes').textContent)
  const S = data.strings
  const ns = 'http://www.w3.org/2000/svg'
  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches
  for (const fig of document.querySelectorAll('figure.drag')) {
    const sc = data.scenarios[+fig.dataset.k]
    const svg = fig.querySelector('svg'), bg = svg.querySelector('.bg'), fg = svg.querySelector('.fg'),
          top = svg.querySelector('.overlay'), finger = svg.querySelector('.finger')
    const nodes = {}
    for (const key in sc.tiles) {
      const g = document.createElementNS(ns, 'g')
      g.setAttribute('class', 'item')
      g.innerHTML = S[sc.tiles[key]]
      fg.appendChild(g)
      nodes[key] = g
    }
    let i = 0, timer = null, shownB = -1, heldKey = ''
    const show = (f) => {
      const b = sc.boards[f.b]
      if (f.b !== shownB) { bg.innerHTML = S[b.bg]; top.innerHTML = S[b.top]; shownB = f.b }
      if (f.k !== heldKey) {
        if (heldKey) nodes[heldKey].setAttribute('class', 'item')
        if (f.k) { nodes[f.k].setAttribute('class', 'item lifted'); fg.appendChild(nodes[f.k]) }
        heldKey = f.k
      }
      for (const key in nodes) {
        const p = key === f.k ? f.p : b.pos[key]
        nodes[key].style.transform = `translate(${p[0]}px, ${p[1]}px)`
      }
      finger.setAttribute('cx', f.p[0]); finger.setAttribute('cy', f.p[1])
      finger.style.opacity = f.p[0] > -50 ? 1 : 0
    }
    const step = () => {
      show(sc.frames[i])
      i += 1
      if (i >= sc.frames.length) { i = 0; timer = setTimeout(step, 1400) }
      else timer = setTimeout(step, 55)
    }
    const play = () => { if (!timer) step() }
    const stop = () => { clearTimeout(timer); timer = null }
    show(sc.frames[reduce ? sc.frames.length - 1 : 0])
    fig.querySelector('.replay').addEventListener('click', () => { stop(); i = 0; play() })
    svg.addEventListener('click', () => { if (timer) stop(); else play() })
    if (!reduce) new IntersectionObserver((es) => {
      for (const e of es) { if (e.isIntersecting) play(); else stop() }
    }, {threshold: 0.4}).observe(fig)
  }
})()
</script>"""

const svgDefs* = """<svg width="0" height="0" style="position:absolute"><defs><filter id="rough"><feTurbulence type="fractalNoise" baseFrequency=".035" numOctaves="2" seed="7"/><feDisplacementMap in="SourceGraphic" scale="5"/></filter><filter id="cutout"><feTurbulence type="fractalNoise" baseFrequency=".012" numOctaves="1" seed="3"/><feDisplacementMap in="SourceGraphic" scale="9"/></filter></defs></svg>"""

proc runScenarios*(root: string, page = "index.html"): (JsonNode, string) =
  ## runs tools/specdrag.nim on the built game `page` and returns its frames and its report
  let tmp = getTempDir() / "parloku-specframes.json"
  let (outp, _) = execCmdEx("nim r --hints:off " & quoteShell(root / "tools" / "specdrag.nim") & " --page:" &
    quoteShell(page) & " --json:" & quoteShell(tmp), workingDir = root)
  (parseFile(tmp), outp.strip)
