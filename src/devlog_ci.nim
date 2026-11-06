## Devlog post: the pages are built in CI. Why we stopped committing the HTML, how one program builds every page,
## what the caches do, and where the CI goes next. Writes devlog/ci/index.html.
import std/[json, os, strutils, algorithm]
import nimib
import style

const devlogStyle = """
<style>
.kicker{font:700 .72rem/1.2 var(--font-body,sans-serif);letter-spacing:.12em;text-transform:uppercase;color:var(--muted);margin:1.6rem 0 .3rem}
.flow{list-style:none;padding:0;margin:14px 0;display:grid;gap:6px}
.flow li{background:var(--card);border:1.5px solid var(--line);border-radius:12px;padding:8px 12px;font-size:15.5px}
.flow li span{font:600 11px "JetBrains Mono",monospace;letter-spacing:.06em;text-transform:uppercase;color:var(--muted);display:block}
.tablewrap{overflow-x:auto}
table.ba{border-collapse:collapse;font-size:.92rem;width:100%;}
table.ba th,table.ba td{padding:.45rem .5rem;border-bottom:1px solid var(--line);text-align:left;vertical-align:top}
table.ba td.n{text-align:right;font-family:"JetBrains Mono",monospace;white-space:nowrap}
.ask{background:var(--card);border:1.5px dashed var(--line);border-radius:14px;padding:6px 18px}
</style>
"""

let root = currentSourcePath().parentDir.parentDir

nbInit
nb.doc.filename = root / "devlog" / "ci" / "index.html"
nb.doc.context["title"] = %"Parloku devlog · built in CI"
nb.doc.context["stylesheet"] = %(pageStyle & devlogStyle)
nb.doc.context["highlight"] = %""
nb.doc.context["disableHighlightJs"] = %true
func pageHeader(blk: JsonNode, nb: Nb): string =
  """<header><span><a href="../../">parloku</a> · devlog</span><span>06 Nov 2026</span></header>"""
nb.backend.partials["header"] = pageHeader

# the pages this very build makes, found the way src/all.nim finds them
var pages: seq[string]
for kind, path in walkDir(root / "src"):
  let (_, name, ext) = path.splitFile
  if kind == pcFile and ext == ".nim" and name != "all" and "\nnbInit" in "\n" & readFile(path):
    pages.add name
pages.sort

nbRawHtml: """
<p class="kicker">DEVLOG · BEHIND THE SCENES</p>
<h1>Built in CI</h1>
<p class="lede">Until today every page of Parloku was built on someone's machine and committed as HTML.
Now GitHub builds them on every push, and the site is deployed from what it built. This is the why, the how,
and the plan for growing it.</p>
"""

nbRawHtml: """<h2><span class="num">01 · WHY</span>HTML in git goes stale</h2>"""

nbText: """
Parloku is a set of [nimib](https://github.com/pietroppeter/nimib) notebooks: Nim files that write HTML pages, with the
game's code compiled to JavaScript. Committing the pages they write had two costs.

- **Pages drifted from their sources.** When we moved to CI, the how-to-play page and the three devlog posts on `main`
  had not been rebuilt after the latest style and game changes. Nobody had done anything wrong: a post embeds the game,
  so every change to the game silently made every post old.
- **Parallel work collided.** Several threads work on Parloku at the same time, each in its own pull request. A
  one-line change to the game rewrites thousands of lines of generated JavaScript in `index.html`, so two pull
  requests that touch different things in the game still conflict on the same file.

With the build in CI, git holds only sources, and the site is always exactly what the sources say.
"""

nbRawHtml: """<h2><span class="num">02 · HOW</span>One program, three caches</h2>"""

nbText: """
Two tricks come from [nanuq](https://github.com/pietroppeter/nanuq) and
[nanuq-book](https://github.com/pietroppeter/nanuq-book), where the docs had the same problem at a bigger scale.

**One program for every page.** Compiling a nimib notebook is mostly compiling nimib and the standard library to C,
and that work is the same for every page. `src/all.nim` imports every page into one program: one compile, one link.
Each page renders when its module starts, in import order, so the game goes first and the posts that embed it come after.
A page is any `src/*.nim` that calls `nbInit`, found at compile time, so a new post needs no list anywhere.
"""

nbRawHtml: "<p>This build found " & $pages.len & " pages: <code>" & pages.join("</code>, <code>") & "</code>.</p>"

nbText: """
**Caches.** Nim keeps the C it generated in `~/.cache/nim` and only recompiles the files whose C changed, so keeping
that folder between runs turns a cold compile into a warm one. The cache key moves with the sources, but every run
starts from the latest cache, which is always safe to reuse. Two smaller caches skip downloads: the pinned
dependencies (`src/deps.sh`) and the `libpcre3` package nimib's markdown needs (the Ubuntu mirror alone can take a minute).
"""

nbRawHtml: """
<div class="tablewrap"><table class="ba">
<tr><th>building every page</th><th>time</th></tr>
<tr><td>page by page, as before (one program per page)</td><td class="n">≈ 2 min</td></tr>
<tr><td>one program, cold</td><td class="n">≈ 20 s</td></tr>
<tr><td>one program, warm Nim cache</td><td class="n">≈ 3 s</td></tr>
<tr><td>the whole CI job, first run (installs included)</td><td class="n">≈ 1 min</td></tr>
</table></div>
<p style="font-size:14px;color:var(--muted)">Measured on a 4-core machine and on GitHub's runner, 6 November 2026.</p>
"""

nbText: "The workflow, `.github/workflows/pages.yml`, step by step:"

nbRawHtml: """
<ol class="flow">
<li><span>guard</span>fail if a generated <code>.html</code> is committed again</li>
<li><span>set up</span>Nim 2.2.4, libpcre3 and the pinned dependencies, from their caches</li>
<li><span>build</span><code>nim c -r -d:release src/all.nim</code>, with the Nim cache</li>
<li><span>assemble</span>the tracked files (pictures, data) plus the built pages, and nothing else</li>
<li><span>deploy</span>only from <code>main</code>: the site on GitHub Pages is replaced in one step</li>
</ol>
"""

nbText: """
Pull requests run the same build, so a branch that breaks a page shows a red check before it reaches `main`.
Locally nothing changes: `nim c -r -d:release src/all.nim` builds the whole site, and a single page still builds on its own.
"""

nbRawHtml: """<h2><span class="num">03 · NEXT</span>How the CI grows</h2>"""

nbText: """
The rule for growing it: **a check joins CI when we catch ourselves running it by hand.** In rough order:

1. **Specs that run.** The OpenSpec page plays its drag scenarios on the game's code while it builds. When it lands, CI
   gets the browser it needs, and a broken scenario turns the build red.
2. **Gesture tests.** The drag tests in `tests/gestures/` run in a headless browser. In CI they would check every
   pull request on the real built pages, and keep the screenshots as artifacts.
3. **Previews of a pull request.** Today a branch's site can be downloaded from its run. A preview link would let us try a
   change on a phone before merging, which is how most changes here get judged.
4. **Puzzles checked in CI.** The build already checks that every puzzle in `data/` has one solution that matches its key.
   With more puzzles (and a daily one) that check, and a logic-path check, become the important part of the build.
5. **Rebuild only what changed.** nanuq-book records which files each chapter reads and reruns only the chapters whose
   inputs changed. With a handful of pages and a 3 s warm build we don't need it yet; with a page per daily puzzle we might.
6. **A weekly build against puzzlepaw's main**, to notice early when the solver changes under the builder.
"""

nbRawHtml: """<div class="ask">"""
nbText: """
**Today's game, or the game as it was?** A devlog post slices its game out of the built `index.html`, so it embeds
*today's* game. That's the default: a post about the splash or about the screen layout still reads fine with a newer game.
One post didn't: *Ten skins* is about switching skins, and the game has since dropped its skin picker (only Niki now).
With today's game the post lost its subject, so it now embeds a **snapshot**: the game and its CSS from an old commit,
read with `git show fc3e6b4:index.html` while the page builds. The rule: a post pins a snapshot only when today's
game contradicts what the post shows.
"""
nbRawHtml: """</div>"""

nbSave
