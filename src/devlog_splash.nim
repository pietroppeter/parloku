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
.ask{background:var(--card);border:1.5px dashed var(--line);border-radius:14px;padding:6px 18px}
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
  """<header><span><a href="../../">parloku</a> · devlog</span><span>05 Nov 2026</span></header>"""
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
to be made of the same six letters, which become the six symbols of a mini sudoku. It should work for people who
don't know sudoku, people who know sudoku but not the 6×6 one, and people who know both.

This is a first prototype of both. Try them here (they are the real ones from the game page):
"""

nbRawHtml: """
<div class="try">
  <button class="btn tut" onclick="parlokuSplash.splash(true)">👋 splash, first visit</button>
  <button class="btn" onclick="parlokuSplash.splash(false)">👋 splash, coming back</button>
  <button class="btn" onclick="parlokuSplash.lesson()">🎬 the first lesson</button>
</div>
<p style="font-size:14px;color:var(--muted)">The language and the skin follow the game below: switch them there and open the splash again.</p>
"""

# ---------------------------------------------------------------- 01 the splash
nbRawHtml: """<h2><span class="num">01 · THE SPLASH</span>Hello, today</h2>"""

nbText: """
The splash is one card, read top to bottom in about three seconds:

- **The date**, as your device says it: *giovedì 5 novembre*. A daily game lives by the date.
- **A greeting by the hour**: good morning, good afternoon, good evening, or *hello, night owl* after eleven.
- **The line of the day**, one of 21 short playful sentences (*"Thirty-six cells, zero rush."*), plus a few special
  days (new year, Halloween, Christmas). The line is picked by the date, not at random, so everyone gets the same line on the same day,
  the way everyone will get the same puzzle.
- **The name**, with its letters popping in as tiles in the skin's colours, and what it is: *a mini sudoku with words*.

**The first time** you open the game on a device, the splash waits for you, and asks *First time here?* with two answers:
*How do I play? 👀* and *I know it, let's play*. So someone who already plays on another phone is one tap away from the game.
**After that**, the splash goes away by itself after a little more than three seconds (a thin bar shows the time), or straight away if you tap,
and *how do I play?* stays as a small link for whoever wants it.

It shows only on the game page. The devlog posts, like this one, embed the game without it, and links such as `?tutorial`
(the 🎓 coach) skip it too. The device remembers that it has seen the splash in `localStorage`, like it remembers your skin.
"""

nbRawHtml: """<p style="margin-bottom:0">The next seven lines, starting today:</p><ul class="week" id="week"></ul>"""

# ---------------------------------------------------------------- 02 the lesson
nbRawHtml: """<h2><span class="num">02 · THE FIRST LESSON</span>From three words to a puzzle</h2>"""

nbText: """
The lesson is an animation in six short beats. Each beat ends with a *next →* button, so it goes at the reader's speed,
and *skip ✕* is always in the corner. It uses the real first puzzle, so it ends exactly where the game begins.
"""

nbRawHtml: """
<ol class="beats">
  <li><b>Three words.</b>ITALIA, PASTA and ALPI appear one at a time, as plain white tiles.</li>
  <li><b>Six letters.</b>The tiles take their colours, and you see that the same colours keep coming back. Then all the A's fly to one spot,
    all the I's to another, and so on: fifteen tiles collapse into six. <i>“One copy of each goes down here: these are our six symbols.
    Six different symbols are just what a mini sudoku needs.”</i></li>
  <li><b>Do you know what a mini sudoku is?</b> Three answers: <i>No, what's a sudoku?</i> · <i>I know sudoku, not the mini one</i> ·
    <i>Yes, I know it</i>.</li>
  <li class="upd"><b>Update, 6 Nov 2026.</b> Pietro dropped this question: everyone now gets the full explanation, since hearing it again
    does no harm. The lesson embedded on this page is today's, so it has no question; the table below records the first version.</li>
  <li><b>The mini sudoku, at your level.</b> The 6×6 grid appears above the six symbols, and tiles fly up from them into the cells (see the table below).</li>
  <li><b>The words are in the grid.</b> On the solved grid, ITALIA lights up from its start cell, ringed in the word's colour, one step at a time, while the other
    letters fade. <i>“Up, down, left or right. Never diagonally.”</i> Then PASTA and ALPI.</li>
  <li><b>How a puzzle starts.</b> Every tile flies back home except the three given letters, and the three coloured start rings stay.
    <i>“The words are clues: they tell you where letters go.”</i> Then: <i>“To play, pull a copy out of a letter below the board and drop it on a cell.
    Want me to guide your first puzzle?”</i> <b>🎓 Guide me</b> starts the coach on puzzle 1, <b>Just play</b> closes the lesson.</li>
</ol>
<div class="tablewrap"><table class="ba">
<tr><th>Your answer</th><th>What beat 4 shows</th><th>Steps</th></tr>
<tr><td>No, what's a sudoku?</td><td>The grid and the goal (fill every cell with one of the six symbols). Then one rule at a time,
  each shown by filling it: a row, a column, a 2×3 box. Then the rest of the grid fills in: “no repeats in any row, column or box”.</td><td>5</td></tr>
<tr><td>I know sudoku, not the mini one</td><td>“A sudoku, only smaller: 6×6 instead of 9×9, boxes of 2×3, six symbols instead of nine digits.”
  The six boxes light up in turn, then the grid fills in.</td><td>2</td></tr>
<tr><td>Yes, I know it</td><td>The grid fills in at once: “then there is only one new thing”.</td><td>0</td></tr>
</table></div>
"""

nbText: """
A few choices behind it:

- **The word variant is never named.** No “wordoku”: the lesson only says that the symbols are letters and the words are hidden in the grid.
- **The question asks what you know, not who you are.** Nobody is a “beginner”; you just haven't met sudoku yet.
- **It shows instead of telling.** Every rule comes with tiles moving, and the text under the board is at most two short sentences.
- **The three words come back.** They start the lesson as words, become the symbols, and come back as paths in the grid. That is the whole idea of Parloku in one loop.
- **It follows the game.** Same skin colours, same language (EN/IT), and it hands over to the 🎓 coach that already exists for the step-by-step solving.
  With *reduce motion* switched on in the device settings, the animations are nearly instant.
"""

# ---------------------------------------------------------------- 03 open
nbRawHtml: """<h2><span class="num">03 · FOR PIETRO</span>Open questions</h2>"""

nbRawHtml: """<div class="ask">"""
nbText: """
- **The tone of the daily lines.** Are they playful enough, too much, too adult? They are easy to rewrite, and could be written
  together with your daughter.
- **Should the splash talk about today's puzzle?** Once there is a daily puzzle it could say *Parloku #12* or hint at today's letters.
- **Should the lesson be reachable later?** Today it is the link on the splash and `?learn`. A *?* button next to 🎓 would be easy.
- **Is beat 6 enough for dragging?** The 🎓 coach teaches the drag in the game itself, so the lesson only mentions it.
- **Nim or JavaScript?** This prototype is plain JavaScript in `src/splash.nim`. If the idea stays, it can be ported to Nim like the rest of the game.
"""
nbRawHtml: "</div>"

nbText: """
To see the first visit again on the game page, open it with `?splash=first`. `?learn` opens the lesson directly,
`?nosplash` skips the splash, and `?day=2026-12-25` previews the line of another day.
"""

nbRawHtml: """<h2><span class="num">04 · THE GAME</span>Where the lesson hands over</h2>"""
nbRawHtml: builtinList
nbRawHtml: game
nbRawHtml: skinsRow
nbRawHtml: overlay
nbRawHtml: gameScript
nbRawHtml: """<script>
document.addEventListener('DOMContentLoaded', () => {
  const week = document.getElementById('week');
  const draw = () => {
    const it = document.documentElement.lang === 'it';
    let html = '';
    for (let i = 0; i < 7; i++) {
      const d = new Date(); d.setDate(d.getDate() + i);
      const day = d.toLocaleDateString(it ? 'it-IT' : 'en-GB', {weekday: 'long', day: 'numeric', month: 'long'});
      html += `<li><span>${day}</span>${parlokuSplash.lineFor(d)}</li>`;
    }
    week.innerHTML = html;
  };
  draw();
  document.getElementById('langs').addEventListener('click', () => setTimeout(draw, 0));
});
</script>"""

nbSave
