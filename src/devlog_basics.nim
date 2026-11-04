## Devlog post: back to basics. Breaks the game screen into named pieces, gives each one a job, explains UI design
## from first principles in a few steps, and embeds the game as rebuilt with that advice.
## Build ../index.html first (src/parloku.nim). The "before" picture comes from src/devlog_basics/before.js.
import std/[json, os, strutils, strformat, sequtils]
import nimib
import style

const devlogStyle = """
<style>
.kicker{font:700 .72rem/1.2 var(--font-body,sans-serif);letter-spacing:.12em;text-transform:uppercase;color:var(--muted);margin:1.6rem 0 .3rem}
.parts{display:grid;grid-template-columns:minmax(0,340px) minmax(0,1fr);gap:24px;align-items:start;margin:18px 0}
@media (max-width:700px){.parts{grid-template-columns:1fr}}
.shot{position:relative;margin:0;border:1.5px solid var(--line);border-radius:14px;overflow:hidden;background:var(--card);max-width:340px;justify-self:center}
@media (min-width:701px){.shot{position:sticky;top:12px}}
.shot img{display:block;width:100%;height:auto}
.shot .box{position:absolute;border:2px solid var(--c0);border-radius:8px;background:transparent;opacity:.55;transition:opacity .2s,background .2s}
.shot .box b{position:absolute;left:-9px;top:-9px;width:20px;height:20px;border-radius:50%;background:var(--c0);color:#fff;
  font:700 11px/20px "JetBrains Mono",monospace;text-align:center}
.shot .box.on{opacity:1;background:color-mix(in srgb,var(--c0) 14%,transparent);border-width:3px}
.shot.dim .box:not(.on){opacity:.15}
ol.list{list-style:none;padding:0;margin:0;display:grid;gap:8px}
ol.list li{background:var(--card);border:1.5px solid var(--line);border-radius:12px;padding:8px 12px 8px 44px;position:relative;cursor:pointer;line-height:1.45;font-size:15.5px}
ol.list li::before{content:attr(data-n);position:absolute;left:10px;top:9px;width:24px;height:24px;border-radius:50%;background:var(--c0);color:#fff;
  font:700 12px/24px "JetBrains Mono",monospace;text-align:center}
ol.list li.on{border-color:var(--ink)}
ol.list li h4{margin:0;font:700 16px var(--font-head)}
ol.list li .when{font:600 11px "JetBrains Mono",monospace;letter-spacing:.06em;text-transform:uppercase;padding:1px 6px;border-radius:6px;margin-left:6px;vertical-align:2px}
.w-always{background:#d7f0dd;color:#1d5b2c} .w-sometimes{background:#dce8fb;color:#1f4f8f} .w-once{background:#fbefd0;color:#6d4c00} .w-never{background:#f6dcdc;color:#8a1f1f}
ol.list li p{margin:4px 0 0}
ol.list li .crop{display:none;margin:8px 0 2px;border:1.5px solid var(--line);border-radius:8px;background-image:url(before.png);background-repeat:no-repeat}
@media (max-width:700px){ol.list li.on .crop{display:block}}
ol.list li .v{font-weight:700}
.steps{counter-reset:step;list-style:none;padding:0}
.steps > li{counter-increment:step;position:relative;padding-left:52px;margin:22px 0}
.steps > li::before{content:counter(step);position:absolute;left:0;top:0;width:36px;height:36px;border-radius:12px;background:var(--g2);color:var(--i2);
  font:700 18px/36px var(--font-head);text-align:center}
.steps > li > b:first-child{font:700 19px var(--font-head);display:block;margin-bottom:2px}
.steps .here{background:var(--card);border-left:4px solid var(--c1);border-radius:0 10px 10px 0;padding:8px 12px;margin:8px 0 0;font-size:15.5px}
.tablewrap{overflow-x:auto}
table.ba{border-collapse:collapse;font-size:.9rem;width:100%;min-width:420px}
table.ba th,table.ba td{padding:.4rem .5rem;border-bottom:1px solid var(--line);text-align:left;vertical-align:top}
table.ba td:nth-child(n+2){white-space:nowrap}
.watch{background:var(--card);border:1.5px dashed var(--line);border-radius:14px;padding:6px 18px}
</style>
"""

let root = currentSourcePath().parentDir.parentDir

nbInit
nb.doc.filename = root / "devlog" / "basics" / "index.html"
nb.doc.context["title"] = %"Parloku devlog · back to basics"
nb.doc.context["stylesheet"] = %(pageStyle & devlogStyle)
nb.doc.context["highlight"] = %""
nb.doc.context["disableHighlightJs"] = %true
func pageHeader(blk: JsonNode, nb: Nb): string =
  """<header><span><a href="../../">parloku</a> · devlog</span><span>04 Nov 2026</span></header>"""
nb.backend.partials["header"] = pageHeader

# ---- the game, as built: only the playing parts of ../index.html
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

nbRawHtml: """
<p class="kicker">DEVLOG · 02</p>
<h1>Back to basics: what is each piece for?</h1>
<p class="lede">Before changing colours again, we take the game screen apart. Every piece gets a name and a job.
Then come the few rules designers use to decide what stays, what moves and what goes, and the game rebuilt with them.</p>
"""

nbText: """
Pietro said he doesn't know how to design a user interface from first principles. Neither does most of the
software that ships. The good news is that the first principles are few and plain, and you can check each one by looking.
This post applies them to Parloku as it was this morning, one piece at a time.
"""

# ---------------------------------------------------------------- 01 the pieces
nbRawHtml: """<h2><span class="num">01 · THE PIECES</span>Taking the screen apart</h2>"""

nbText: """
Here is the game as it was, on a phone, halfway through puzzle 1. I gave every piece a number and a name.
For each one, the list says its **job** (what it is for, in a few words), **when** a player needs it, and what I did with it.
Tap a piece in the list to see it in the picture.
"""

type Part = object
  key, name, job, wh, verdict: string

let parts = @[
  Part(key: "header", name: "Header line", wh: "never",
    job: "Says “parloku · a wordoku you drag”, which the title says again right below.",
    verdict: "Cut. Two pieces doing one job."),
  Part(key: "skins", name: "Skin bar", wh: "once",
    job: "Picks the look. You choose it once, then you play.",
    verdict: "Moved below the game. It took the most important spot on the screen, the top."),
  Part(key: "langs", name: "Language switch", wh: "once",
    job: "English or Italian.",
    verdict: "Moved into the row with the puzzle choice, so all the “before you play” choices are in one place."),
  Part(key: "title", name: "Title and intro", wh: "once",
    job: "Tells a newcomer what this is.",
    verdict: "Kept, shorter. “Drag the tiles up from their stacks” went: the stacks look like something you grab."),
  Part(key: "picker", name: "Puzzle chooser and tutorial", wh: "sometimes",
    job: "Pick a puzzle, or learn how to play.",
    verdict: "Kept, as numbers. The puzzle names repeated the words that are already on the clue cards, and took two rows."),
  Part(key: "clues", name: "Clue cards", wh: "always",
    job: "The goal: the words to spell. Their letters colour in as you spell them, so they also show progress.",
    verdict: "Kept. Tapping one now highlights its path on the board: phones have no hover, so this was mouse-only."),
  Part(key: "marker", name: "Start markers", wh: "always",
    job: "Where each word starts. Same number and colour as its clue card.",
    verdict: "Kept, a bit bigger. At about 13 px they were the smallest thing on the screen, but you need them all the time."),
  Part(key: "board", name: "Board", wh: "always",
    job: "The play space: 36 cells in six 2×3 boxes.",
    verdict: "Kept. In several skins the empty cells were white on a white card, so you couldn’t see where cells began. Every cell now has a faint edge."),
  Part(key: "given", name: "Given tiles", wh: "always",
    job: "Letters that come with the puzzle. The dashed ring means “fixed, you can’t move me”.",
    verdict: "Kept."),
  Part(key: "stacks", name: "Letter stacks", wh: "always",
    job: "The supply of tiles. The height of a stack shows how many are left, and an empty one turns into a ✓.",
    verdict: "Kept. It is also the best progress bar on the screen (see 12)."),
  Part(key: "machinery", name: "“show machinery” box", wh: "never",
    job: "Shows how the drag engine works. A developer tool, not a game tool.",
    verdict: "Moved to the explainer section on the game page, next to the code it explains."),
  Part(key: "meta", name: "Stats line", wh: "never",
    job: "Tiles placed, moves, a ticking clock.",
    verdict: "Cut. The tile count repeated the stacks, and a clock ticking every second is pressure, not help, for a seven-year-old. Moves and time still appear at the end, in the Bravo! banner."),
  Part(key: "actions", name: "Action buttons", wh: "sometimes",
    job: "Hint, reset, share a link.",
    verdict: "Kept, plus a new ↶ undo. Reset now asks “sure?” first, and on touch screens all buttons are 44 px tall (they were 28 to 32)."),
  Part(key: "rules", name: "Rules cards", wh: "once",
    job: "The three rules, for anyone who wants to read them.",
    verdict: "Kept, below the game, where they don’t get in the way."),
]
let boxes = parseJson(readFile(root / "devlog" / "basics" / "before.json"))

block:
  var fig = """<div class="parts"><figure class="shot" id="shot"><img src="before.png" alt="The Parloku game screen before this post, on a phone, with its pieces numbered" width="780" height="2334">"""
  var list = """<ol class="list" id="parts">"""
  for i, p in parts:
    let b = boxes[p.key]
    fig.add &"""<span class="box" data-part="{i}" style="left:{b[0].getFloat}%;top:{b[1].getFloat}%;width:{b[2].getFloat}%;height:{b[3].getFloat}%"><b>{i + 1}</b></span>"""
    list.add &"""<li data-part="{i}" data-n="{i + 1}"><h4>{p.name}<span class="when w-{p.wh}">{p.wh}</span></h4>""" &
      &"""<p>{p.job}</p><p><span class="v">→</span> {p.verdict}</p></li>"""
  nbRawHtml: fig & "</figure>" & list & "</ol></div>"

nbText: """
Some pieces don't show up in a still picture, because they only appear when something happens. They matter just as much:

- **The lifted tile.** It grows and casts a shadow while you hold it: *you are holding this*.
- **The landing preview.** While you drag, the board already shows where the tile will land: *this is what will happen*.
- **The red cell.** Two equal letters in a row, column or box: *this breaks a rule*.
- **The word path.** A line follows a word as you spell it, dotted until the word is complete: *you are on the right track*.
- **The ✓ marks** on a finished clue card and on an empty stack: *this part is done*.
- **The Bravo! banner and the letter confetti**: *you won*.
- **The coach**, only in the tutorial: *here is the next step and why*.
"""

# ---------------------------------------------------------------- 02 the method
nbRawHtml: """<h2><span class="num">02 · FIRST PRINCIPLES</span>Designing a game screen in ten steps</h2>"""

nbText: """
These steps come from a few classic sources. Don Norman's *The Design of Everyday Things* gave the words for
feedback, signifiers and mapping. Jakob Nielsen's ten usability heuristics cover undo, consistency and “less is more”.
Two other ideas from psychology fill in the rest: Fitts's law, about how fast a finger reaches a target, and the
Gestalt law of proximity, about how the eye groups things. I've put them in the order I'd use them, with what each one
meant for Parloku.
"""

nbRawHtml: """
<ol class="steps">
<li><b>Write the loop in one sentence.</b>
A game is a loop the player repeats hundreds of times. Every piece on the screen should help one step of that loop,
or the start or end of it. If it doesn't, it is decoration at best and in the way at worst.
<div class="here"><b>Parloku:</b> look at the clues and the board → pick a letter from a stack → drop it on a cell → see if it fits.
Before the loop: choose a puzzle. After it: Bravo!</div></li>

<li><b>Make a parts list, and give every part one job.</b>
Name each piece and write its job in a few words. A piece you can't give a job to is clutter. Two pieces with the
same job are clutter too: keep the better one.
<div class="here"><b>Parloku:</b> the header repeated the title. The stats line counted tiles, which the stacks already show
better, because you see <i>which</i> letters are left, not just how many.</div></li>

<li><b>Sort the parts by when they are needed.</b>
Some pieces are needed <i>always</i>, some <i>sometimes</i>, some <i>once</i> and some <i>never while playing</i>.
“Always” pieces get the space and the middle of the screen. “Once” pieces go out of the way, and “never” pieces
leave the play area.
<div class="here"><b>Parloku:</b> five always (clues, markers, board, givens, stacks), two sometimes (puzzle choice,
actions), four once (skin, language, title, rules) and three never (header, machinery, stats). Before, a
“once” piece, the skin bar, sat at the very top.</div></li>

<li><b>Keep the whole loop on one screen.</b>
If a step of the loop is off screen, the player scrolls, and the screen moves under their hand. On a phone, dragging and
scrolling also fight each other: you can't drag a tile from a stack below the fold to a cell above it.
<div class="here"><b>Parloku:</b> on an iPhone 13 (664 px of page in the browser), the stacks ended at 794 px, below the fold.
Now the board and stacks end at 644 px: clues, board and stacks are all visible together.</div></li>

<li><b>Things that work together sit together.</b>
The eye groups what is close (Gestalt proximity). So put each thing next to what it works with, and keep unrelated
things apart.
<div class="here"><b>Parloku:</b> clues right above the board, the stacks right below it, the actions right under the stacks.
The “before you play” choices (tutorial, puzzle, language) now share one row.</div></li>

<li><b>One signal, one meaning.</b>
If a colour means a letter, it should always mean that letter, and never also “danger” or “selected”.
Players learn the code once and read it everywhere, and redundant cues help everyone.
<div class="here"><b>Parloku:</b> colour means letter, on tiles, stacks and spelled clue letters. A number and its colour mean a word,
on the clue card and on its start marker. Red cell means rule broken, and nothing else. Some skins also give each letter
its own shape, so colour-blind players get a second cue.</div></li>

<li><b>Every action gets an answer.</b>
Feedback: the screen must answer every touch, right away, and show what is about to happen before it happens.
Silence makes people press again, or give up.
<div class="here"><b>Parloku:</b> pick up → the tile grows. Drag → the board previews the landing. Drop → the tile glides in.
Then you see red cells, word paths and ✓ marks, and finally Bravo!. The missing answer was on phones: “show me where this word
goes” worked only with a mouse hover. Now a tap on a clue card does it.</div></li>

<li><b>Make mistakes cheap.</b>
People explore by trying. If a mistake is cheap, they try more and learn faster. If one tap can wipe their work,
they get careful and stop playing.
<div class="here"><b>Parloku:</b> dragging a tile away already sent it home. New: <b>↶ undo</b> takes back the last change, and
<b>↺ reset</b>, the one button that wipes the board, asks “sure?” before it does.</div></li>

<li><b>Make it fit fingers.</b>
Fitts's law: the smaller and farther a target, the slower and less accurate the tap. Fingers are much bigger than mouse
pointers. Apple and the accessibility guidelines both say about 44 px for anything you tap.
<div class="here"><b>Parloku:</b> buttons were 28 to 32 px. On touch screens they are now 44 px. Board cells were already about
47 px, and the stacks are spread across the whole width.</div></li>

<li><b>Watch a real player, and don't explain.</b>
Every step above is a guess until somebody plays. Sit next to them, say nothing, and note where they hesitate.
Every pause is a piece that didn't do its job.
<div class="here"><b>Parloku:</b> this is the one step I can't do. The checklist below is for Pietro.</div></li>
</ol>
"""

# ---------------------------------------------------------------- 03 before / after
nbRawHtml: """<h2><span class="num">03 · BEFORE AND AFTER</span>What changed, measured</h2>"""

nbText: """
Measured on an iPhone 13 screen in Chromium, Munari skin, puzzle 1:
"""

nbRawHtml: """<div class="tablewrap"><table class="ba">
<tr><th></th><th>before</th><th>after</th></tr>
<tr><td>pieces above the rules</td><td>13</td><td>8</td></tr>
<tr><td>bottom of the stacks</td><td>794 px (below the fold)</td><td>644 px (on screen)</td></tr>
<tr><td>rows for choosing a puzzle</td><td>2</td><td>1, with the language</td></tr>
<tr><td>button height on touch</td><td>28–32 px</td><td>44 px</td></tr>
<tr><td>things that move on their own</td><td>a clock, every second</td><td>none</td></tr>
<tr><td>see a word's path on a phone</td><td>no (hover only)</td><td>tap its clue card</td></tr>
<tr><td>take back a move</td><td>drag the tile away</td><td>drag it away, or ↶ undo</td></tr>
<tr><td>wipe the board by accident</td><td>one tap</td><td>needs two taps</td></tr>
<tr><td>empty cells visible in every skin</td><td>no</td><td>yes, with a faint edge</td></tr>
</table></div>"""

nbText: "Here is the game as it is now. Play it, then scroll up and compare with the picture."

nbRawHtml: game & skinsRow & builtinList

# ---------------------------------------------------------------- 04 watch
nbRawHtml: """<h2><span class="num">04 · THE TEST</span>What to watch when she plays</h2>"""

nbRawHtml: """<div class="watch">
<p>Hand over the phone with the first puzzle open, say “it's a game with letters”, and nothing else. Then watch:</p>
<ol>
<li><b>Where does she tap first?</b> Tapping a tile instead of dragging it means the stacks don't look draggable enough.</li>
<li><b>Does she find the stacks without help?</b> If not, the tray needs to call for attention, for example with a small wiggle.</li>
<li><b>Does she understand the numbered dots?</b> Does she put the first letter of a word on its dot by herself?</li>
<li><b>What does she do on a red cell?</b> Does she fix it, or ignore it?</li>
<li><b>What does she do when stuck?</b> Look for 💡? Ask you? Stop? That shows whether the hint is easy enough to find.</li>
<li><b>Does she use ↶ undo or ↺ reset, and does “sure?” confuse her?</b></li>
<li><b>When does she lose interest?</b> At about which tile, and what was on the screen at that moment?</li>
</ol>
<p>Then try the 🎓 tutorial with her, and see whether the coach's sentences are short enough for a seven-year-old.</p>
</div>"""

# ---------------------------------------------------------------- 05 next
nbRawHtml: """<h2><span class="num">05 · STILL OPEN</span>Not fixed yet</h2>"""

nbText: """
- **No keyboard play.** You can only play with a mouse or a finger. Moving with the arrow keys and typing letters would
  help people who can't drag, and it would be quicker for grown-ups.
- **The clue cards wrap to two rows on phones.** A shorter card, with the word drawn as dots until it is spelled, would
  fit in one row and give the board more room.
- **The start marker covers a corner of the first tile.** It is readable, but a marker outside the cell, or a ring around
  it, could be cleaner.
- **The test with a real player**, step 10 above.
"""

nbRawHtml: gameScript
nbRawHtml: """<script>
// tap a piece in the list to find it in the picture (and the other way round)
(function () {
  const shot = document.getElementById('shot'), list = document.getElementById('parts');
  let on = -1;
  // on phones the picture is far from the list: each piece gets its own crop of it, shown when tapped
  const W = 780, H = 2334, pad = 2;
  list.querySelectorAll('li').forEach(li => {
    const b = shot.querySelector('.box[data-part="' + li.dataset.part + '"]').style;
    let [x, y, w, h] = [b.left, b.top, b.width, b.height].map(parseFloat);
    x = Math.max(0, x - pad); w = Math.min(100 - x, w + 2 * pad);
    const hp = pad * W / H; y = Math.max(0, y - hp); h = Math.min(100 - y, h + 2 * hp);
    const c = document.createElement('div');
    c.className = 'crop';
    c.style.aspectRatio = (w * W) + ' / ' + (h * H);
    c.style.backgroundSize = (10000 / w) + '% auto';
    c.style.backgroundPosition = (w < 100 ? x / (100 - w) * 100 : 0) + '% ' + (h < 100 ? y / (100 - h) * 100 : 0) + '%';
    li.appendChild(c);
  });
  const show = i => {
    on = (on === i) ? -1 : i;
    shot.classList.toggle('dim', on >= 0);
    document.querySelectorAll('[data-part]').forEach(e => e.classList.toggle('on', +e.dataset.part === on));
  };
  list.addEventListener('click', e => { const li = e.target.closest('li'); if (li) show(+li.dataset.part); });
  shot.addEventListener('click', e => { const b = e.target.closest('.box'); if (b) { show(+b.dataset.part);
    if (on >= 0) list.querySelector('li[data-part="' + on + '"]').scrollIntoView({behavior: 'smooth', block: 'nearest'}); } });
})();
</script>"""

nbSave
