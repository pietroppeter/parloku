## The devlog's index: every post, newest first. Writes devlog/index.html.
## The list is read from the posts' sources (src/devlog_*.nim, and src/parloku.nim for "How it works"):
## each post's folder, the date in its header, its kicker, title and lede. A new post needs no entry here.
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
  if not (name.startsWith("devlog_") or name == "parloku"): continue
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
</style>""")
nb.doc.context["highlight"] = %""
nb.doc.context["disableHighlightJs"] = %true
func pageHeader(blk: JsonNode, nb: Nb): string =
  """<header><span><a href="../">parloku</a> · devlog</span><span>every post</span></header>"""
nb.backend.partials["header"] = pageHeader

var items = ""
for p in posts:
  items.add &"""<li><a href="{p.slug}/"><span class="when">{p.date} · {p.kicker.replace("DEVLOG · ", "")}</span><h2>{p.title}</h2><p>{p.lede}</p></a></li>"""

nbRawHtml: &"""
<p class="kicker">DEVLOG</p>
<h1>How Parloku is made</h1>
<p class="lede">Dated posts on the steps in the game's evolution: what changed, why, and what we tried on the way.
Newest first.</p>
<ul class="posts">{items}</ul>
<p><a href="../">← to the game</a></p>
"""
nbSave
