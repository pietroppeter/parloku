## The devlog's index. Writes devlog/index.html, in two parts:
## - the living documents, pages kept up to date as the game changes: a fixed table below (add a row for a new one);
## - the dated posts, newest first, read from their sources (src/devlog_*.nim): each post's folder, the date in its
##   header, its kicker, title and lede. A new post needs no entry here.
import std/[json, os, re, strutils, algorithm, times, strformat]
import nimib
import style

let root = currentSourcePath().parentDir.parentDir

type Post = object
  slug, date, kicker, title, lede: string
  day: DateTime

proc first(s: string, pattern: Regex): string =
  var m: array[1, string]
  if s.find(pattern, m) >= 0: m[0].strip else: ""

proc postOf(src: string): Post =
  result.slug = src.first(re"""root / "devlog" / "([a-z0-9-]+)" / "index.html"""")
  result.date = src.first(re"<span>(\d\d \w{3} \d{4})</span></header>")
  result.kicker = src.first(re"""<p class="kicker">([^<]*)</p>""")
  result.title = src.first(re"<h1>([^<]*)</h1>")
  result.lede = src.first(re("""<p class="lede">(.*?)</p>""", {reDotAll}))
  if result.date != "": result.day = parse(result.date, "dd MMM yyyy")

var posts: seq[Post]
for kind, path in walkDir(root / "src"):
  let (_, name, ext) = path.splitFile
  if kind != pcFile or ext != ".nim" or name == "devlog_index": continue
  if not name.startsWith("devlog_"): continue
  let p = postOf(readFile(path))
  if p.slug != "" and p.title != "" and p.date != "": posts.add p
posts.sort(proc (a, b: Post): int = (if a.day == b.day: cmp(b.kicker, a.kicker) else: cmp(b.day, a.day)))   # same day: the later number first

nbInit
nb.doc.filename = root / "devlog" / "index.html"
nb.doc.context["title"] = %"Parloku devlog"
nb.doc.context["stylesheet"] = %(pageStyle & """
<style>
.kicker{font:700 .72rem/1.2 var(--font-body,sans-serif);letter-spacing:.12em;text-transform:uppercase;color:var(--muted);margin:1.6rem 0 .3rem}
.posts{list-style:none;padding:0;margin:18px 0;display:grid;gap:12px}
.posts a{display:block;text-decoration:none;color:inherit;background:var(--card);border:var(--border) solid var(--line);border-radius:16px;padding:12px 16px}
.posts a:hover{border-color:var(--ink)}
.posts .when{font:600 11px "JetBrains Mono",monospace;letter-spacing:.08em;text-transform:uppercase;color:var(--muted)}
.posts h2{font-size:21px;margin:4px 0 4px}
.posts p{margin:0;color:var(--muted);line-height:1.45}
h2.part{font-size:24px;margin:2rem 0 .3rem}
.living{list-style:none;padding:0;margin:14px 0 8px;background:var(--card);border:var(--border) solid var(--line);border-radius:16px}
.living li{padding:10px 16px;border-top:1px solid var(--line);line-height:1.4;color:var(--muted)}
.living li:first-child{border-top:0}
.living a{font-weight:700;color:var(--ink);text-decoration:none}
.living a:hover{text-decoration:underline}
.living small{display:block;margin-top:2px;font:600 10.5px "JetBrains Mono",monospace;letter-spacing:.06em;text-transform:uppercase}
</style>""")
nb.doc.context["highlight"] = %""
nb.doc.context["disableHighlightJs"] = %true
func pageHeader(blk: JsonNode, nb: Nb): string =
  """<header><span><a href="../">parloku</a> · devlog</span><span>living pages · posts</span></header>"""
nb.backend.partials["header"] = pageHeader

# Living documents: pages kept up to date as the game changes. Links are relative to devlog/.
type Living = tuple[href, title, what, updated: string]
let living: seq[Living] = @[
  ("../specs/", "Specs", "How Parloku behaves today: the puzzle, the screens, the gestures, with scenarios that play.",
   "on every push, from openspec/"),
  ("how-it-works/", "How it works", "The game's own notebook: the model, the rules as code, the solver, the drag spec.",
   "with every change to the game"),
  ("../istruzioni.html", "Istruzioni", "How to play, in Italian: the rules, then each gesture with a board to try it on.",
   "when a rule or a gesture changes"),
  ("../garden/feste/", "Le feste", "The dances the letters do when a puzzle is solved, each one on a board to finish.",
   "when a dance is added or changed"),
  ("../builder.html", "Builder", "Make a new puzzle with the game's board and gestures.",
   "when the builder changes"),
  ("../builder-howto.html", "Builder how-to", "How the builder works, tool by tool.",
   "when the builder changes"),
  ("../spiega.html", "Spiega", "Any puzzle explained step by step, with moves a person can check (?p=<code>).",
   "when the step solver changes"),
]
var docs = ""
for d in living:
  docs.add &"""<li><a href="{d.href}">{d.title}</a>: {d.what}<small>updated {d.updated}</small></li>"""

var items = ""
for p in posts:
  items.add &"""<li><a href="{p.slug}/"><span class="when">{p.date} · {p.kicker.replace("DEVLOG · ", "")}</span><h2>{p.title}</h2><p>{p.lede}</p></a></li>"""

nbRawHtml: &"""
<p class="kicker">DEVLOG</p>
<h1>How Parloku is made</h1>
<p class="lede">Living documents that say how the game is today, then dated posts on the steps that led here.</p>
<h2 class="part">Living documents</h2>
<p>Kept up to date as the game changes.</p>
<ul class="living">{docs}</ul>
<h2 class="part">Posts</h2>
<p>Each tells one step as it happened: what changed, why, and what we tried on the way. They are not updated
afterwards. Newest first.</p>
<ul class="posts">{items}</ul>
<p><a href="../">← to the game</a></p>
"""
nbSave
