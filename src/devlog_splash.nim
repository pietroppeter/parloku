## Devlog post: a daily splash and a first lesson. Shows both on demand, explains the design, lists open questions.
## Build ../index.html first (src/parloku.nim): the game and the splash are sliced from it.
import std/[json, os, strutils]
import nimib
import style, splash

const devlogStyle = """
<style>
.kicker{font:700 .72rem/1.2 var(--font-body,sans-serif);letter-spacing:.12em;text-transform:uppercase;color:var(--muted);margin:1.6rem 0 .3rem}
.try{display:flex;gap:8px;flex-wrap:wrap;margin:14px 0 6px}
.try .btn{font-size:14px;padding:8px 14px}
.beats{counter-reset:beat;list-style:none;padding:0}
.beats > li{counter-increment:beat;position:relative;padding-left:52px;margin:18px 0}
.beats > li::before{content:counter(beat);position:absolute;left:0;top:0;width:36px;height:36px;border-radius:12px;background:var(--g2);color:var(--i2);
  font:700 18px/36px var(--font-head);text-align:center}
.beats > li > b:first-child{font:700 18px var(--font-head);display:block;margin-bottom:2px}
.tablewrap{overflow-x:auto}
table.ba{border-collapse:collapse;font-size:.92rem;width:100%;min-width:440px}
table.ba th,table.ba td{padding:.45rem .5rem;border-bottom:1px solid var(--line);text-align:left;vertical-align:top}
.week{list-style:none;padding:0;margin:10px 0;display:grid;gap:6px}
.week li{background:var(--card);border:1.5px solid var(--line);border-radius:12px;padding:8px 12px;font-size:15.5px}
.week li span{font:600 11px "JetBrains Mono",monospace;letter-spacing:.06em;text-transform:uppercase;color:var(--muted);display:block}
.ask{background:var(--card);border:1.5px solid var(--line);border-radius:14px;padding:6px 18px}
</style>
"""

let root = currentSourcePath().parentDir.parentDir

nbInit
nb.doc.filename = root / "devlog" / "splash" / "index.html"
nb.doc.context["title"] = %"Parloku devlog · a daily hello and a first lesson"
nb.doc.context["stylesheet"] = %(pageStyle & devlogStyle & splashCss)
nb.doc.context["highlight"] = %""
nb.doc.context["disableHighlightJs"] = %true
func pageHeader(blk: JsonNode, nb: Nb): string =
  """<header><span><a href="../../">parloku</a> · <a href="../">devlog</a></span><span>05 Nov 2026</span></header>"""
nb.backend.partials["header"] = pageHeader

# ---- the game and the splash, as built in ../index.html
let built = readFile(root / "index.html")
proc slice(s, start, stop: string): string =
  let a = s.find(start)
  let b = s.find(stop, a)
  doAssert a >= 0 and b > a, "index.html is missing " & start & ": build src/parloku.nim first"
  s[a ..< b]
let skinsRow = slice(built, """<div class="skins"""", "\n")
let game = slice(built, """<div class="game">""", """<div class="rules">""")
let builtinList = slice(built, """<template id="builtin">""", "\n")
let gameScript = slice(built, "<script>", "</script>") & "</script>"
let overlay = slice(built, """<div class="sp" id="splash"""", "<!-- /splash -->").replace(
  """<div class="sp" id="splash"""", """<div class="sp" id="splash" data-manual""")

nbRawHtml: """
<p class="kicker">DEVLOG · 03</p>
<h1>A daily hello, and a first lesson</h1>
<p class="lede">Parloku will be a daily game, so it should say hello every day. And someone who lands here for the
first time needs to learn what a mini sudoku is, and what the words are for, without reading a rulebook.</p>
"""

nbText: """
Pietro's idea, in his words: a short splash screen every time you open the game, that says what day it is,
says something playful that changes every day, and says what Parloku is, *a mini sudoku with words*.
The first time, it should offer a way into a tutorial that you can skip, because you may already know the game
and just be on a new phone. The tutorial should be an animation: three words, ITALIA, PASTA, ALPI, that turn out
to be made of the same six letters, which become the six symbols of a mini sudoku.

*Updated on 6 November 2026.* The splash and the lesson are now Nim, like the rest of the game. The lesson no longer
asks what you know, it has the game's look, and the splash has no language switch. Section 03 lists every switch.
Try them here (they are the real ones from the game page):
"""

nbRawHtml: """
<div class="try">
  <button class="btn tut" data-show="first">👋 splash, first visit</button>
  <button class="btn" data-show="again">👋 splash, coming back</button>
  <button class="btn" data-show="lesson">🎬 the first lesson</button>
</div>
"""

# ---------------------------------------------------------------- 01 the splash
nbRawHtml: """<h2><span class="num">01 · THE SPLASH</span>Hello, today</h2>"""

nbText: """
The splash is one card over the game, read top to bottom in about three seconds:

- **The date**, as your device says it: *giovedì 5 novembre*. A daily game lives by the date.
- **A greeting by the hour**: *buongiorno* from 5 to 12, *buon pomeriggio* until 18, *buonasera* until 23,
  and *ciao, nottambulo* through the night.
- **The line of the day**, one of 21 short playful sentences (*"Trentasei caselle, zero fretta."*), plus three special
  days: 1 January, 31 October and 25 December. The line is picked by the date, not at random, so everyone gets the same line
  on the same day, the way everyone will get the same puzzle.
- **The name**, with its letters popping in as tiles in the game's colours, and what it is: *un mini sudoku con parole*.

**The first time** you open the game on a device, the splash waits for you, and asks *È la prima volta qui?* with two answers:
*Come si gioca? 👀*, which opens the lesson, and *Lo conosco, si gioca*. So someone who already plays on another phone is one tap away from the game.
**After that**, the splash goes away by itself after 3.2 seconds (a thin bar fills up meanwhile), or straight away with a tap outside it
or on *Gioca ▸*. *come si gioca?* stays as a small link for whoever wants the lesson.
"""

nbRawHtml: """<p style="margin-bottom:0">The next seven lines, starting today:</p><ul class="week" id="week"></ul>"""

# ---------------------------------------------------------------- 02 the lesson
nbRawHtml: """<h2><span class="num">02 · THE FIRST LESSON</span>From three words to a puzzle</h2>"""

nbText: """
The lesson is an animation in seven short beats (the seven dots at the top). Each step ends with an *avanti →* button, so it
goes at the reader's speed, and *salta ✕* is always in the corner. It uses an example of its own, so it spoils no puzzle, and it looks like the game: the classic grid, round tiles, a rounded square on each word's start cell and a thin outline along each word.
"""

nbRawHtml: """
<ol class="beats">
  <li><b>Three words.</b>AMARENA, MENTA and MARE (a summer day: each word is also the colour of its outline, red, green and
    blue) appear one at a time, as plain white tiles. They are an example of the lesson's own,
    not one of the game's puzzles, so the lesson gives nothing away. In its grid no word turns back on itself in a U, as in the
    game's puzzles.</li>
  <li><b>Six letters.</b>The tiles take their colours, and you see that the same colours keep coming back. Then all the A's fly to one spot,
    all the M's to another, and so on: sixteen tiles collapse into six. <i>“Una copia di ognuna si mette giù: sono i nostri sei simboli.”</i></li>
  <li><b>The mini sudoku.</b> The 6×6 grid appears above the six symbols. Then one rule at a time, each shown by filling it with tiles
    that fly up from the symbols: a row, a column, a 2×3 box. Then the rest of the grid fills in: <i>“nessun doppione in righe, colonne e riquadri”</i>.</li>
  <li><b>The words are in the grid.</b> On the solved example, the three words move up above the grid in their colours, as in the game, and AMARENA lights
    up from its start cell, one step at a time, while the other
    letters fade. <i>“Su, giù, a destra o a sinistra. Mai in diagonale.”</i> Then MENTA and MARE.</li>
  <li><b>How a puzzle starts.</b> Every tile flies back home except three given letters, and the three start cells stay.
    <i>“Le parole sono indizi: ti dicono dove vanno le lettere.”</i></li>
  <li><b>The gestures.</b> A finger shows them one by one: dragging a letter onto a cell; a double tap on a word's
    start cell; stretching AMARENA from its last letter; a double tap on the last free cell of the bottom row (the only other cell a
    double tap fills); and a double tap on AMARENA's second letter, which takes it back with the letters after it.</li>
  <li><b>Over to you,</b> the way Simon does it on Cracking the Cryptic: the rules are told, now pick how to go on. <b>▸ Gioco da solo</b>,
    <b>🎓 Guidami</b> (with a spoiler warning: the tutorial solves the first puzzle step by step), or <b>📖 Istruzioni</b>, where every gesture
    has a small board to try it on.</li>
</ol>
"""

nbText: """
**What changed on 6 November.** The lesson used to walk the first puzzle's solution; now it has its own example, shows the gestures,
and ends with three choices. The first version also asked *Do you know what a mini sudoku is?* before beat 3, with three answers:
*No, what's a sudoku?* got the five steps above, *I know sudoku, not the mini one* got two (a sudoku, only smaller), and *Yes, I know it*
got none. Pietro dropped the question: hearing the rules again does no harm, and one path is simpler for everyone.

A few choices behind it:

- **The word variant is never named.** No “wordoku”: the lesson only says that the symbols are letters and the words are hidden in the grid.
- **It shows instead of telling.** Every rule comes with tiles moving, and the text under the board is at most two short sentences.
- **The three words come back.** They start the lesson as words, become the symbols, and come back as paths in the grid. That is the whole idea of Parloku in one loop.
- **It follows the game.** The same colours and the same language (Italian; the English draft with `?lang=en`), and it hands over to the 🎓 tutorial.
  With *reduce motion* switched on in the device settings, the animations are nearly instant.
"""

# ---------------------------------------------------------------- 03 every switch
nbRawHtml: """<h2><span class="num">03 · EVERY SWITCH</span>When it shows, and how to see it again</h2>"""

nbRawHtml: """
<div class="tablewrap"><table class="ba">
<tr><th>What</th><th>How</th></tr>
<tr><td>The first-visit splash</td><td>Shown until the device remembers <code>parloku:seen</code> in its storage; set when the splash or the lesson closes.
  Again with <code>?splash=first</code>.</td></tr>
<tr><td>The coming-back splash</td><td>Every other visit to the game page. It closes by itself after 3.2 s.</td></tr>
<tr><td>The lesson</td><td><i>Come si gioca?</i> on the splash, or <code>?learn</code> to open it directly. Finishing it sets <code>parloku:learned</code>.</td></tr>
<tr><td>Another day</td><td><code>?day=2026-12-25</code> shows that day's date and line, at the current hour.</td></tr>
<tr><td>No splash</td><td><code>?nosplash</code>, and also <code>?tutorial</code> (straight into the tutorial). The devlog posts and the istruzioni boards never show it by themselves.</td></tr>
<tr><td>On another page</td><td>The overlay with <code>data-manual</code> opens only when asked: <code>parlokuSplash.splash(first)</code>, <code>.lesson()</code>,
  and <code>.lineFor(date)</code> for the line of any day. This post uses them.</td></tr>
<tr><td>The English draft</td><td><code>?lang=en</code>, for the splash and the lesson too.</td></tr>
</table></div>
"""

nbText: """
**How it is built.** `src/splash.nim` holds the card's markup and style. The behaviour is `src/splashrt.nim`, Nim compiled to
JavaScript together with the game's script. The lesson's puzzle (letters, solution, given cells, words) rides in data attributes of the
overlay, written at build time from the first puzzle. The lesson's steps are `async` Nim procs that `await` short pauses; closing the lesson
bumps a counter, and every pause checks it, so a closed lesson stops at its next pause. `tests/gestures/splash.js` checks the first visit,
coming back, another day, skipping and *Guidami*.
"""

# ---------------------------------------------------------------- 04 open
nbRawHtml: """<h2><span class="num">04 · FOR PIETRO</span>Open questions</h2>"""

nbRawHtml: """<div class="ask">"""
nbText: """
- **The tone of the daily lines.** Are they playful enough, too much, too adult? They are easy to rewrite, and could be written
  together with your daughter.
- **Should the splash talk about today's puzzle?** Once there is a daily puzzle it could say *Parloku #12* or hint at today's letters.
- **Should the lesson be reachable later?** Today it is the link on the splash and `?learn`. The istruzioni page could link it too.
- ~~Nim or JavaScript?~~ Nim, since 6 November.
"""
nbRawHtml: "</div>"

nbRawHtml: """<h2><span class="num">04 · THE GAME</span>Where the lesson hands over</h2>"""
nbRawHtml: builtinList
nbRawHtml: game
nbRawHtml: skinsRow
nbRawHtml: overlay
nbRawHtml: gameScript
nbJsFromCode:
  import std/dom
  type JsDate = ref object of JsRoot
  proc lineFor(d: JsDate): cstring {.importjs: "parlokuSplash.lineFor(#)".}
  proc showSplash(first: bool) {.importjs: "parlokuSplash.splash(#)".}
  proc showLesson() {.importjs: "parlokuSplash.lesson()".}
  proc inDays(n: int): JsDate {.importjs: "(n => { const d = new Date(); d.setDate(d.getDate() + n); return d })(#)".}
  proc longDate(d: JsDate, loc: cstring): cstring {.importjs: "#.toLocaleDateString(#, {weekday: 'long', day: 'numeric', month: 'long'})".}
  proc docLang(): cstring {.importjs: "String(document.documentElement.lang)".}
  proc dataOf(ev: Event, k: cstring): cstring {.importjs: "((e, k) => e.target.closest('[data-' + k + ']')?.getAttribute('data-' + k) ?? null)(#, #)".}
  document.addEventListener("DOMContentLoaded", proc (ev: Event) =
    # the next seven lines of the day
    let loc: cstring = if docLang() == "it": "it-IT" else: "en-GB"
    var html = ""
    for i in 0 ..< 7:
      let d = inDays(i)
      html.add "<li><span>" & $d.longDate(loc) & "</span>" & $lineFor(d) & "</li>"
    document.getElementById("week").innerHTML = cstring(html)
    document.querySelector(".try").addEventListener("click", proc (ev: Event) =
      let what = dataOf(ev, "show")
      if what == "first": showSplash(true)
      elif what == "again": showSplash(false)
      elif what == "lesson": showLesson()))

nbSave
