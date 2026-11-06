## Page CSS. Every colour, font and tile shape comes from CSS variables and classes, so a *skin*
## (`[data-skin=...]`) restyles the page, the board and the tiles without touching the Nim code.
## Twelve skins: Niki de Saint Phalle (the default), ten pastel ones after artists and illustrators, and the original maiolica.
## Inlined in place of nimib's default theme (only Google Fonts is external).

const fonts = "https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,700;0,900;1,700" &
  "&family=Karla:wght@400;600;700&family=JetBrains+Mono:wght@400;600&family=Nunito:wght@400;700;800" &
  "&family=Fredoka:wght@500;600;700&family=Patrick+Hand&family=Zen+Maru+Gothic:wght@500;700" &
  "&family=Josefin+Sans:wght@400;600;700&family=DM+Serif+Display&family=Space+Grotesk:wght@400;500;700&family=Baloo+2:wght@600;800&display=swap"

const skinList* = [
  # (id, label, origin) — the switcher shows them in this order
  ("niki", "Niki", "🇫🇷"), ("munari", "Munari", "🇮🇹"), ("tullet", "Tullet", "🇫🇷"), ("lionni", "Lionni", "🇮🇹"),
  ("miro", "Miró", "🇪🇸"), ("gomi", "Gomi", "🇯🇵"), ("wagashi", "Wagashi", "🇯🇵"),
  ("delaunay", "Delaunay", "🇫🇷"), ("bruna", "Bruna", "🇳🇱"), ("matisse", "Matisse", "🇫🇷"),
  ("isola", "Isola", "🇫🇮"), ("maiolica", "Maiolica", "🏺")]

const pageStyle* = """
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="""" & fonts & """" rel="stylesheet">
<style>
/* ---------- the default skin: Munari (also the fallback for every variable) ---------- */
:root,[data-skin=munari]{
  --bg:#fbfaf6; --card:#ffffff; --ink:#2b2b2b; --muted:#6b665c; --line:#e7e3d8; --soft:#f3f1ea;
  --accent:#a7c7e7; --accent-ink:#2b2b2b; --hl:#fff1b8; --bad:#ffd3d3; --bad-line:#e06666;
  --g0:#f4a6a6; --g1:#f9e29c; --g2:#a7c7e7; --g3:#f8c291; --g4:#b8e0b0; --g5:#cdb4db;
  --i0:#2b2b2b; --i1:#2b2b2b; --i2:#2b2b2b; --i3:#2b2b2b; --i4:#2b2b2b; --i5:#2b2b2b;
  --c0:#c0392b; --c1:#3a6db0; --c2:#a8650a; --c3:#6c4f99; --c4:#2f7a4d;
  --frame:transparent; --ca:#ffffff; --cb:#f3f1ea; --boxline:#2b2b2b; --tstroke:none; --tsw:0;
  --font-head:"Space Grotesk",system-ui,sans-serif; --font-body:Nunito,system-ui,sans-serif;
  --font-glyph:"Space Grotesk",system-ui,sans-serif; --glyph-weight:700; --shine:0;
  --radius:16px; --border:1.5px; --shadow:none; --btn-shadow:none; --coach:#2b2b2b; --coach-ink:#fbfaf6;
}
/* ---------- Niki de Saint Phalle (France): bright Nanas, soft blobs with a black outline ---------- */
[data-skin=niki]{
  --bg:#fff8ef; --card:#ffffff; --ink:#1e1e1e; --muted:#5b5348; --line:#f0e2cf; --soft:#fff1e0; --accent:#ffe066; --accent-ink:#1e1e1e;
  --g0:#ffb3c6; --g1:#ffe066; --g2:#8fd2ff; --g3:#b5f0a0; --g4:#ffb98a; --g5:#d9b5ff;
  --i0:#1e1e1e; --i1:#1e1e1e; --i2:#1e1e1e; --i3:#1e1e1e; --i4:#1e1e1e; --i5:#1e1e1e;
  --w0:#c01c3a; --w1:#0a7552; --w2:#1b3f9e;   /* red, green, blue: in RGB order */
  --frame:transparent; --ca:#ffffff; --cb:#fff1e0; --boxline:#1e1e1e; --tstroke:#1e1e1e; --tsw:2.5px;
  --font-head:"Baloo 2",system-ui,sans-serif; --font-body:"Baloo 2",Nunito,system-ui,sans-serif;
  --font-glyph:"Baloo 2",system-ui,sans-serif; --glyph-weight:800; --coach:#1e1e1e; --hl:#fff3b0;
}
[data-skin=niki] .tile .rd,[data-skin=niki] .layer .rd{display:none}
[data-skin=niki] .tile .bl,[data-skin=niki] .layer .bl{display:inline}
*{box-sizing:border-box}
[hidden]{display:none!important}
:root{padding:env(safe-area-inset-top,0) env(safe-area-inset-right,0) env(safe-area-inset-bottom,0) env(safe-area-inset-left,0)}
html{background:var(--bg)}
body{margin:0 auto;max-width:760px;padding:0 16px 60px;color:var(--ink);font:17px/1.6 var(--font-body);background:var(--bg);
  transition:background .3s}
header,footer .nb-box{display:flex;justify-content:space-between;align-items:center;gap:10px;flex-wrap:wrap;font-size:13px;color:var(--muted);padding:12px 0}
header{font-family:"JetBrains Mono",monospace}
footer .nb-box{border-top:1px solid var(--line);margin-top:40px}
header a, footer a{color:var(--muted)}
h1,h2,h3{font-family:var(--font-head);line-height:1.08;letter-spacing:-.01em}
h1{font-size:clamp(44px,10vw,72px);font-weight:700;margin:18px 0 4px}
h1 .tile{display:inline-block;width:.92em;height:.92em;line-height:.92em;text-align:center;border-radius:.2em;
  background:var(--g2);color:var(--i2);font-size:.82em;margin-right:.04em;vertical-align:.04em;border:var(--tsw-h,0) solid var(--ink)}
h2{font-size:28px;font-weight:700;margin:52px 0 10px;padding-top:18px;border-top:2px solid var(--line)}
h2 .num{font-family:"JetBrains Mono",monospace;font-size:13px;color:var(--c0);display:block;margin-bottom:6px;letter-spacing:.1em}
a{color:var(--c1);text-decoration-thickness:1px;text-underline-offset:3px}
p code, li code{font:14.5px "JetBrains Mono",monospace;background:var(--soft);padding:1px 5px;border-radius:4px;overflow-wrap:anywhere}
.lede{font-size:19px;color:var(--muted);margin-top:4px}
pre{margin:14px 0;overflow-x:auto;border-radius:10px}
pre code{display:block;padding:14px 16px;font:13.2px/1.55 "JetBrains Mono",monospace;background:var(--card);border:1px solid var(--line);border-radius:10px;color:var(--ink)}
pre.nb-output, pre samp{display:block;padding:12px 16px;font:13px/1.5 "JetBrains Mono",monospace;background:#2b2b2b;color:#f3f1ea;border-radius:10px;white-space:pre;overflow-x:auto}
details{margin:14px 0;border:1px solid var(--line);border-radius:10px;padding:4px 12px;background:var(--card)}
details summary{cursor:pointer;font-family:"JetBrains Mono",monospace;font-size:13px;color:var(--muted);padding:6px 0}
/* skin switcher */
.skins{display:flex;gap:8px;overflow-x:auto;padding:10px 2px 8px;margin:0 -16px;padding-left:16px;scrollbar-width:none}
.skins::-webkit-scrollbar{display:none}
.skins button{flex:none;display:flex;align-items:center;gap:6px;font:600 13px var(--font-body);color:var(--ink);background:var(--card);
  border:1.5px solid var(--line);border-radius:999px;padding:5px 11px 5px 7px;cursor:pointer}
.skins button.on{border-color:var(--ink);box-shadow:0 0 0 2px var(--ink) inset}
.skins .dots{display:flex}
.skins .dots i:nth-child(1){background:var(--g0)} .skins .dots i:nth-child(2){background:var(--g1)} .skins .dots i:nth-child(3){background:var(--g2)}
.skins .dots i{width:13px;height:13px;border-radius:50%;margin-right:-4px;border:1.5px solid var(--card)}
/* game */
.game{margin:14px 0 8px}
.picker{display:flex;flex-wrap:wrap;gap:8px;align-items:center;margin:0 0 12px}
.picker > span{display:contents}
.btn{font:700 13px var(--font-body);border:var(--border) solid var(--ink);background:var(--card);color:var(--ink);
  border-radius:999px;padding:6px 14px;cursor:pointer;box-shadow:var(--btn-shadow)}
.btn.on{background:var(--accent);color:var(--accent-ink)}
.btn.tut{background:var(--hl)}
.btn:active{transform:translate(1px,1px);box-shadow:none}
.langs{display:flex;gap:6px;margin-left:auto}
.langs .btn{padding:4px 10px}
/* the tutorial's messages: a white-ish, see-through blob floating over the game, placed (in Nim) off what the step is about */
.coach{position:fixed;z-index:15;left:0;right:0;top:0;margin:0 auto;width:min(calc(100vw - 24px),400px);box-sizing:border-box;
  background:rgba(255,255,255,.84);-webkit-backdrop-filter:blur(1px);backdrop-filter:blur(1px);color:var(--ink);
  border-radius:30px 24px 32px 22px / 24px 30px 22px 32px;padding:10px 16px 12px;
  box-shadow:0 6px 24px rgba(0,0,0,.14),0 0 0 1px rgba(0,0,0,.05);transition:top .35s ease;touch-action:none;cursor:grab;user-select:none;-webkit-user-select:none}
.coach.held{transition:none;cursor:grabbing;box-shadow:0 10px 30px rgba(0,0,0,.2),0 0 0 1px rgba(0,0,0,.06)}
.coach .hd{font:700 11px "JetBrains Mono",monospace;letter-spacing:.1em;color:var(--muted)}
.coach p{margin:4px 0 8px;font-size:15px;line-height:1.4}
.coach p b{background:rgba(0,0,0,.07);padding:0 4px;border-radius:4px}
.coach .acts{display:flex;gap:8px;flex-wrap:wrap}
.coach .acts .btn{padding:5px 12px;font-size:14px}
@media (prefers-reduced-motion:reduce){.coach{transition:none}}
.pulse{animation:pulse 1.2s ease-in-out infinite}
@keyframes pulse{50%{opacity:.35}}
.clues{display:flex;flex-wrap:wrap;gap:10px 14px;justify-content:center;margin:6px 0 12px;min-height:46px}
.clue{display:flex;align-items:center;gap:6px;padding:6px 10px 6px 6px;border-radius:var(--radius);background:var(--card);
  border:var(--border) solid var(--line);box-shadow:var(--btn-shadow);cursor:default;transition:transform .2s}
.clue .n{width:26px;height:26px;border-radius:50%;color:#fff;font:700 14px "JetBrains Mono",monospace;display:grid;place-items:center}
.clue .l{width:26px;height:30px;border-radius:7px;display:grid;place-items:center;font:var(--glyph-weight) 18px var(--font-glyph);
  border:1.5px solid var(--line);color:var(--muted);transition:background .25s,color .25s}
/* a clue letter already on the board: bold, dark, with a thick dark edge; the ones still to place stay light */
.clue.done{border-color:var(--ink)}
.clue .ok{font-size:18px;width:18px;text-align:center;color:var(--c4);font-weight:700}
.stage{position:relative;background:var(--card);border:var(--border) solid var(--line);border-radius:calc(var(--radius) + 4px);box-shadow:var(--shadow);padding:6px;overflow:hidden}
.stage svg.d2{display:block;overflow:visible;width:100%;height:auto;touch-action:none;user-select:none;-webkit-user-select:none;-webkit-touch-callout:none}
.stage svg text{font-family:var(--font-body)}
svg .glyph{font-family:var(--font-glyph);font-weight:var(--glyph-weight)}
svg .mono{font-family:"JetBrains Mono",monospace}
.item{transition:transform .34s cubic-bezier(.2,.9,.25,1)}
.item.grab{cursor:grab}
.item.lifted{transition:none;cursor:grabbing;filter:drop-shadow(0 10px 8px rgba(0,0,0,.18))}
.item.lifted > *{transform:scale(1.12)}
/* board and tiles, drawn by the Nim view; skins pick colours and shapes */
.g0{fill:var(--g0)} .g1{fill:var(--g1)} .g2{fill:var(--g2)} .g3{fill:var(--g3)} .g4{fill:var(--g4)} .g5{fill:var(--g5)}
.i0{fill:var(--i0)} .i1{fill:var(--i1)} .i2{fill:var(--i2)} .i3{fill:var(--i3)} .i4{fill:var(--i4)} .i5{fill:var(--i5)}
.tile .sq,.tile .ci,.tile .bl,.layer .sq,.layer .ci,.layer .bl,.ring,.gv{display:none}
.tile rect,.tile circle,.tile path,.layer rect,.layer circle,.layer path{stroke:var(--tstroke);stroke-width:var(--tsw)}
.layer{filter:brightness(.88)}
.tile .ring{fill:none;stroke:rgba(255,255,255,.6);stroke-width:5}
.sh{fill:#fff;opacity:var(--shine)}
/* a given can't move: just a thicker dark outline */
.tile.given rect,.tile.given circle,.tile.given path{stroke:var(--ink);stroke-width:4.5px}
.tile.given .ring{stroke:rgba(255,255,255,.6)}
.frame{fill:var(--frame)}
.cell{stroke:color-mix(in srgb,var(--ink) 16%,transparent);stroke-width:1.5} .cell.ca{fill:var(--ca)} .cell.cb{fill:var(--cb)} .cell.tint{fill:var(--hl)} .cell.bad{fill:var(--bad)}
.badline{fill:none;stroke:var(--bad-line);stroke-width:3}
/* no red while a tile is held: only once it is let go */
/* two letters in conflict tremble, gently at first and more over a few seconds (no red); not while a tile is held */
.dragging .cell.bad.ca{fill:var(--ca)} .dragging .cell.bad.cb{fill:var(--cb)} .dragging .cell.bad.tint{fill:var(--hl)} .dragging .badline{display:none}
@media (prefers-reduced-motion: reduce){.shake .tile rect,.shake .tile circle,.shake .tile path{stroke:var(--bad-line)}}
.boxline{fill:var(--boxline)}
.thin{stroke:color-mix(in srgb,var(--boxline) 35%,transparent);stroke-width:1.5}
.edge{fill:none;stroke:var(--boxline);stroke-width:5}

.lbl{fill:var(--muted);display:none} .tutoring .lbl{display:inline}
.glow{fill:var(--hl);stroke:var(--c0);stroke-width:3}
.empty{fill:none;stroke:var(--line);stroke-width:2} .done{fill:var(--c4)}
.casing{fill:none;stroke:var(--card);stroke-linecap:round;stroke-linejoin:round;opacity:.85}
.wp{fill:none;stroke-linecap:round;stroke-linejoin:round}
.wp.c0{stroke:var(--c0)} .wp.c1{stroke:var(--c1)} .wp.c2{stroke:var(--c2)} .wp.c3{stroke:var(--c3)} .wp.c4{stroke:var(--c4)}
.mk{stroke:var(--card);stroke-width:2.5} .mkt{fill:#fff}
.mk.c0{fill:var(--c0)} .mk.c1{fill:var(--c1)} .mk.c2{fill:var(--c2)} .mk.c3{fill:var(--c3)} .mk.c4{fill:var(--c4)}
.aim{fill:none;stroke:var(--c0);stroke-width:5}
.ghosts,.overlay{pointer-events:none}
.ghosts .target{fill:none;stroke:var(--ink);stroke-width:2;opacity:.35}
.ghosts .land{fill:var(--c0);opacity:.5}
.ghosts .tether{stroke:var(--c0);stroke-width:2;opacity:.6}
.ghost-toggle{position:absolute;right:12px;bottom:6px;font:12px "JetBrains Mono",monospace;color:var(--muted);cursor:pointer;user-select:none}
.ghost-toggle input{accent-color:var(--c0);vertical-align:-2px}
.status{display:flex;flex-wrap:wrap;gap:8px;align-items:center;justify-content:center;margin:12px 0}
.status .meta{font:600 13px "JetBrains Mono",monospace;color:var(--muted)}
.status .meta b{color:var(--ink)}
.status .acts{display:flex;gap:8px;flex-wrap:wrap}
.btn.num{min-width:36px;padding:6px 0;text-align:center}
.picker .btn.num{min-width:0;padding:6px 14px;letter-spacing:.04em;font-weight:700}
.btn:disabled{opacity:.4;cursor:default;box-shadow:none}
.btn:disabled:active{transform:none}
/* words: three dark colours, apart from the six pastel letters; one word per line, left, centre, right */
:root{--w0:#1f5aa6;--w1:#b34700;--w2:#a3195b}
.clues{flex-direction:column;flex-wrap:nowrap;align-items:stretch;gap:8px}
.clue{align-self:flex-start;border-width:3px;padding:5px 10px}
.clue:nth-child(3n+2){align-self:center} .clue:nth-child(3n){align-self:flex-end}
.clue.focus{box-shadow:0 0 0 3px color-mix(in srgb,currentColor 0%,transparent),0 4px 12px rgba(0,0,0,.12)}
.wo,.wl,.wm{fill:none;stroke-linecap:round;stroke-linejoin:round}
.wf.w0{fill:var(--w0)} .wf.w1{fill:var(--w1)} .wf.w2{fill:var(--w2)} .wo.w0,.wl.w0{stroke:var(--w0)} .wo.w1,.wl.w1{stroke:var(--w1)} .wo.w2,.wl.w2{stroke:var(--w2)}
.wo,.wl{transition:stroke-width .2s}
/* tiles that divide */
.neck{stroke:var(--tstroke);stroke-width:var(--tsw)}
.necks,.fx{pointer-events:none}
.ripple{fill:none;stroke-width:4;transform-box:fill-box;transform-origin:center;animation:ripple .45s ease-out forwards}
.ripple.g0{stroke:var(--g0)} .ripple.g1{stroke:var(--g1)} .ripple.g2{stroke:var(--g2)} .ripple.g3{stroke:var(--g3)} .ripple.g4{stroke:var(--g4)} .ripple.g5{stroke:var(--g5)}
@keyframes ripple{from{transform:scale(.95);opacity:.9}to{transform:scale(1.5);opacity:0}}
/* the game page: only the game (focus); tap empty space for the rest (chrome); "more" opens the whole page (explain) */
body.focus>header,body.focus footer,body.chrome>header,body.chrome footer,
body.focus main>:not(.play):not(.sp),body.chrome main>:not(.play):not(.sp){display:none}
body.focus,body.chrome{padding-bottom:0}
body.focus .play,body.chrome .play{min-height:100svh;display:flex;flex-direction:column;justify-content:center;padding:8px 0}
body.demo .play{min-height:0}      /* a practice board on the istruzioni page: as tall as its game */
body.focus .play>h1,body.focus .play>.lede,body.focus .play>.rules,body.focus .play>.skins,
body.chrome .play>h1,body.chrome .play>.lede,body.chrome .play>.rules,
body.focus .status{display:none}
body.focus .game,body.chrome .game{margin:0}
body.chrome .play>.skins{display:none}
.clue .ok:empty{display:none}
/* a tapped clue's ring or outline wiggles on the board */
.wig{animation:wig .65s ease-in-out}
@keyframes wig{0%,100%{transform:none}15%{transform:rotate(-5deg) scale(1.04)}35%{transform:rotate(4deg) scale(1.04)}55%{transform:rotate(-3deg)}75%{transform:rotate(2deg)}}
@media (prefers-reduced-motion: reduce){.wig{animation:none}}
@media (max-width:440px){body.chrome .status .tx{display:none} body.chrome .status .btn{min-width:48px}}
body.chrome .status{position:fixed;left:0;right:0;z-index:20;margin:0 auto;max-width:760px;
  padding:10px 16px;background:color-mix(in srgb,var(--bg) 94%,transparent);-webkit-backdrop-filter:blur(6px);backdrop-filter:blur(6px)}
body.chrome .picker .langs,body.chrome .status,body.chrome .picker .tut,body.chrome .play>.skins,body.focus .picker .langs,body.focus .picker .tut{display:none}
/* the menu: a bar that slides down from the top, while words, grid and letters shrink a little to make room;
   it slides back up after a few idle seconds or a tap in the game. "again!" swaps its buttons for the puzzles, scrolled sideways */
body.focus .picker,body.chrome .picker{display:flex;position:fixed;top:0;left:0;right:0;z-index:20;margin:0 auto;max-width:760px;
  padding:10px 16px;padding-top:max(10px,env(safe-area-inset-top));flex-wrap:nowrap;justify-content:center;gap:8px;
  overflow-x:auto;scrollbar-width:none;background:color-mix(in srgb,var(--bg) 94%,transparent);
  -webkit-backdrop-filter:blur(6px);backdrop-filter:blur(6px);transition:transform .35s ease,visibility .35s}
body.focus .picker{transform:translateY(-105%);visibility:hidden}
body.chrome .picker{transform:none;visibility:visible}
.picker::-webkit-scrollbar{display:none}
.picker>*{flex:none}
.play .clues,.play .stage{transition:transform .35s ease,gap .35s ease}
body.chrome .play .clues{transform:translateY(var(--drop,0px));gap:3px}
body.chrome .play .stage{transform:translateY(calc(var(--drop,0px) - 10px))}
.menu-only{display:none}
body.focus .picker .menu-only,body.chrome .picker .menu-only{display:inline-flex;align-items:center;text-decoration:none;color:inherit}
body.focus .picker #picker,body.chrome .picker #picker{display:none}
body.focus .picker.listing,body.chrome .picker.listing{justify-content:flex-start}
body.focus .picker.listing>:not(#picker),body.chrome .picker.listing>:not(#picker){display:none}
body.focus .picker.listing #picker,body.chrome .picker.listing #picker{display:contents}
#picker .btn{white-space:nowrap;display:inline-flex;gap:6px;align-items:center}
#picker .ck{color:var(--w1);font-weight:800}
#picker .ck:empty{display:none}
@media (max-width:400px){body.chrome .picker{gap:6px;padding-left:8px;padding-right:8px} body.chrome .picker .menu-only{padding:6px 11px;font-size:13px}}
@media (prefers-reduced-motion: reduce){.ripple{animation:none;opacity:0}}
.machinery-slot{margin:10px 0}
.machinery-slot .ghost-toggle{position:static;font-size:14px}
/* fingers are bigger than mouse pointers: 44px targets on touch screens */
@media (pointer:coarse){
  .btn{min-height:44px;padding:8px 16px;font-size:14px}
  .btn.num{min-width:44px;padding:8px 0}
  .picker .btn.num{min-width:0;padding:8px 14px}
  .langs .btn{min-height:40px;padding:6px 12px}
  .skins button{min-height:40px}
}
.banner{position:absolute;left:50%;top:87%;transform:translate(-50%,-50%) scale(.6);opacity:0;pointer-events:none;
  background:var(--card);color:var(--ink);border-radius:var(--radius);padding:14px 28px;text-align:center;border:3px solid var(--ink);
  transition:all .45s cubic-bezier(.2,1.4,.4,1);white-space:nowrap}
.banner b{display:block;font:700 42px var(--font-head)}
.banner span{font:600 13px "JetBrains Mono",monospace;color:var(--muted)}
.stage.won.cheer .banner{opacity:1;transform:translate(-50%,-50%) scale(1)}
.confetti{position:absolute;inset:0;pointer-events:none;overflow:hidden}
.confetti i{position:absolute;left:var(--x);top:-30px;width:20px;height:20px;border-radius:50%;
  font:700 11px/20px var(--font-glyph);text-align:center;font-style:normal;
  animation:fall var(--t) cubic-bezier(.3,.6,.6,1) var(--d) forwards}
@keyframes fall{to{transform:translate(var(--dx),720px) rotate(var(--r))}}
.rules{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;margin:16px 0}
@media (max-width:640px){.rules{grid-template-columns:1fr}}
.rules div{background:var(--card);border:var(--border) solid var(--line);border-radius:var(--radius);padding:10px 12px;font-size:15px;line-height:1.45}
.rules b{font:700 12px "JetBrains Mono",monospace;color:var(--c0);display:block;letter-spacing:.08em;margin-bottom:2px}
.spoiler svg{width:100%;max-width:360px;display:block;margin:8px auto}
@media (max-width:560px){
  header span:nth-child(2){display:none}
  .lede{font-size:15px;margin:0}
  h1{font-size:38px;margin:10px 0 0}
  .clues{gap:8px}
  .clue{gap:3px;padding:4px 6px 4px 4px}
  .clue .n{width:21px;height:21px;font-size:12px}
  .clue .l{width:19px;height:24px;font-size:15px;border-radius:5px}
  .stage{padding:2px}
  .banner b{font-size:32px}
}
@media (prefers-reduced-motion: reduce){
  .pulse,.confetti i{animation:none} .item,.clue,.banner,body{transition:none}
}
.btn:focus-visible,.skins button:focus-visible{outline:3px solid var(--c1);outline-offset:2px}
#source{display:none}
footer button{font:600 12px "JetBrains Mono",monospace;border:1.5px solid var(--ink);background:var(--card);color:var(--ink);border-radius:999px;padding:4px 12px;cursor:pointer}
footer hr{display:none}

/* ---------- 1 · Munari (Italy): white page, circles and squares taking turns, no outlines ---------- */
[data-skin=munari] .s0 .rd{display:none} [data-skin=munari] .s0 .ci{display:inline}
[data-skin=munari] .s1 .rd{display:none} [data-skin=munari] .s1 .sq{display:inline}

/* ---------- 2 · Tullet (France): big round dots on white, red · yellow · blue first ---------- */
[data-skin=tullet]{
  --bg:#ffffff; --card:#ffffff; --ink:#1f1f1f; --line:#ececec; --soft:#f5f5f5; --accent:#ffd86b;
  --g0:#ff8a80; --g1:#ffd86b; --g2:#7fb3ff; --g3:#ffb26b; --g4:#8fd694; --g5:#c29bea;
  --i0:#1f1f1f; --i1:#1f1f1f; --i2:#1f1f1f; --i3:#1f1f1f; --i4:#1f1f1f; --i5:#1f1f1f;
  --c0:#d0353a; --c1:#1f63c4; --c2:#a8650a; --c3:#7a45c9; --c4:#1f7a4d;
  --ca:#ffffff; --cb:#ffffff; --boxline:#1f1f1f; --frame:#1f1f1f;
  --font-head:Fredoka,sans-serif; --font-glyph:Fredoka,sans-serif; --font-body:Nunito,sans-serif; --glyph-weight:600;
  --coach:#1f1f1f; --hl:#fff3b0;
}
[data-skin=tullet] .tile .rd,[data-skin=tullet] .layer .rd{display:none}
[data-skin=tullet] .tile .ci,[data-skin=tullet] .layer .ci{display:inline}
[data-skin=tullet] .cell{stroke:#ececec;stroke-width:1}

/* ---------- 3 · Lionni (Italy): torn-paper collage, soft blues, yellows and greens ---------- */
[data-skin=lionni]{
  --bg:#f4efe6; --card:#fffdf8; --ink:#3b362e; --muted:#6e665a; --line:#e4dccd; --soft:#ece5d8; --accent:#9cc7e8;
  --g0:#8fb8de; --g1:#f6d55c; --g2:#9ccc65; --g3:#ef9a9a; --g4:#e8c39e; --g5:#80cbc4;
  --i0:#24384d; --i1:#4d3d0b; --i2:#2d4a14; --i3:#5a2525; --i4:#5a3f22; --i5:#1f4a46;
  --c0:#c0392b; --c1:#2f6aa3; --c2:#8f6208; --c3:#7a5aa6; --c4:#3d7a2c;
  --ca:#fffdf8; --cb:#f7f1e4; --boxline:#c7bca8; --font-head:"Patrick Hand",cursive; --font-glyph:"Patrick Hand",cursive;
  --glyph-weight:400; --coach:#3b362e; --coach-ink:#fffdf8;
}
[data-skin=lionni] .tile{filter:url(#rough)} [data-skin=lionni] .layer{filter:url(#rough) brightness(.88)}
[data-skin=lionni] svg .glyph{font-size:40px}

/* ---------- 4 · Miró (Spain): cream ground, black lines, a black dot among the colours ---------- */
[data-skin=miro]{
  --bg:#f6f0e1; --card:#fbf7ec; --ink:#1a1a1a; --line:#e3dac4; --soft:#eee6d2; --accent:#f6cf57;
  --g0:#e9786f; --g1:#f6cf57; --g2:#6f9ed8; --g3:#7fbf7f; --g4:#2a2a2a; --g5:#f2a65a;
  --i0:#1a1a1a; --i1:#1a1a1a; --i2:#1a1a1a; --i3:#1a1a1a; --i4:#f6cf57; --i5:#1a1a1a;
  --c0:#c23a2f; --c1:#2d6cc0; --c2:#1a1a1a; --c3:#7d4fb0; --c4:#2e7034;
  --ca:#fbf7ec; --cb:#f3ecda; --boxline:#1a1a1a; --tstroke:#1a1a1a; --tsw:3px; --frame:#1a1a1a;
  --font-head:Fredoka,sans-serif; --font-glyph:Fredoka,sans-serif; --glyph-weight:700; --coach:#1a1a1a; --coach-ink:#f6f0e1;
}
[data-skin=miro] .s0 .rd{display:none} [data-skin=miro] .s0 .ci{display:inline}

/* ---------- 5 · Gomi (Japan): warm sketchbook, wobbly brown lines, sunny colours ---------- */
[data-skin=gomi]{
  --bg:#fff7ee; --card:#fffdf9; --ink:#4a3b32; --muted:#7a6a5c; --line:#f0e1d2; --soft:#fbeee0; --accent:#ffb38a;
  --g0:#ffb38a; --g1:#9ad0f5; --g2:#b5e48c; --g3:#ffadc6; --g4:#ffe08a; --g5:#c3b1e1;
  --i0:#4a3b32; --i1:#4a3b32; --i2:#4a3b32; --i3:#4a3b32; --i4:#4a3b32; --i5:#4a3b32;
  --c0:#c4471f; --c1:#2a73b0; --c2:#3d7a1f; --c3:#a8437f; --c4:#3d7a3d;
  --ca:#fffdf9; --cb:#fff3e4; --boxline:#4a3b32; --tstroke:#4a3b32; --tsw:2.5px;
  --font-head:"Patrick Hand",cursive; --font-glyph:Fredoka,sans-serif; --glyph-weight:600; --coach:#4a3b32; --coach-ink:#fff7ee;
}
[data-skin=gomi] .tile,[data-skin=gomi] .boxline{filter:url(#rough)} [data-skin=gomi] .layer{filter:url(#rough) brightness(.9)}

/* ---------- 6 · Wagashi (Japan): sweets-shop pastels, sakura · matcha · yuzu, rounded and calm ---------- */
[data-skin=wagashi]{
  --bg:#f8f4ec; --card:#fffcf6; --ink:#5a4a42; --muted:#7a6c62; --line:#ece3d6; --soft:#f2ebe0; --accent:#f7c6d0;
  --g0:#f7c6d0; --g1:#b7d3a8; --g2:#f6e3a1; --g3:#d9b38c; --g4:#b8d8e8; --g5:#cdbfe3;
  --i0:#5a4a42; --i1:#3f5233; --i2:#5c4c16; --i3:#5a3a34; --i4:#2f4e5c; --i5:#4b3d63;
  --c0:#b84a68; --c1:#4a7a3c; --c2:#8a6a10; --c3:#6f5aa0; --c4:#4a7a3c;
  --ca:#fffcf6; --cb:#f6efe3; --boxline:#d8cbb8; --font-head:"Zen Maru Gothic",sans-serif;
  --font-glyph:"Zen Maru Gothic",sans-serif; --font-body:"Zen Maru Gothic",Nunito,sans-serif; --glyph-weight:700;
  --radius:22px; --coach:#5a4a42; --coach-ink:#fffcf6;
}

/* ---------- 7 · Delaunay (France): rhythm of concentric circles in bright pastels ---------- */
[data-skin=delaunay]{
  --bg:#fdfbf7; --card:#ffffff; --ink:#263238; --line:#ebe6dc; --soft:#f4efe6; --accent:#a0c4ff;
  --g0:#ff9f9a; --g1:#ffd6a5; --g2:#a0c4ff; --g3:#84dcc6; --g4:#bdb2ff; --g5:#ffc6ff;
  --i0:#263238; --i1:#263238; --i2:#263238; --i3:#263238; --i4:#263238; --i5:#263238;
  --c0:#c9284f; --c1:#0b6a8a; --c2:#b35c00; --c3:#6243e0; --c4:#04785a;
  --ca:#ffffff; --cb:#f6f3ff; --boxline:#263238;
  --font-head:"Josefin Sans",sans-serif; --font-glyph:"Josefin Sans",sans-serif; --glyph-weight:700; --coach:#263238;
}
[data-skin=delaunay] .tile .rd,[data-skin=delaunay] .layer .rd{display:none}
[data-skin=delaunay] .tile .ci,[data-skin=delaunay] .layer .ci,[data-skin=delaunay] .tile .ring{display:inline}

/* ---------- 8 · Bruna (Netherlands): flat colour, thick black outline, nothing else ---------- */
[data-skin=bruna]{
  --bg:#ffffff; --card:#ffffff; --ink:#111111; --line:#111111; --soft:#f2f2f2; --accent:#f9d56e;
  --g0:#f28482; --g1:#f9d56e; --g2:#84a9e8; --g3:#8cc084; --g4:#f5a65b; --g5:#c9a27e;
  --i0:#111; --i1:#111; --i2:#111; --i3:#111; --i4:#111; --i5:#111;
  --c0:#c62834; --c1:#1d6fd8; --c2:#9a6200; --c3:#6a4c93; --c4:#1e7a38;
  --ca:#ffffff; --cb:#ffffff; --boxline:#111; --frame:#111; --tstroke:#111; --tsw:4px; --border:2.5px;
  --font-head:Fredoka,sans-serif; --font-glyph:Fredoka,sans-serif; --glyph-weight:600; --coach:#111;
}
[data-skin=bruna] .tile .rd,[data-skin=bruna] .layer .rd{display:none}
[data-skin=bruna] .tile .sq,[data-skin=bruna] .layer .sq{display:inline}

/* ---------- 9 · Matisse (France): paper cut-outs, cobalt and coral on warm white ---------- */
[data-skin=matisse]{
  --bg:#fbf7f0; --card:#fffdf8; --ink:#22324d; --muted:#666b78; --line:#ece4d6; --soft:#f2ebdf; --accent:#f4a78f;
  --g0:#3f63b0; --g1:#f4a78f; --g2:#9ccfa0; --g3:#f5d77a; --g4:#f2b8c6; --g5:#22324d;
  --i0:#fff; --i1:#22324d; --i2:#22324d; --i3:#22324d; --i4:#22324d; --i5:#f5d77a;
  --c0:#bf4527; --c1:#3456a8; --c2:#2d7a40; --c3:#a8475f; --c4:#2d7a40;
  --ca:#fffdf8; --cb:#f8f0e3; --boxline:#22324d; --font-head:"DM Serif Display",serif; --font-glyph:"DM Serif Display",serif;
  --glyph-weight:400; --coach:#22324d;
}
[data-skin=matisse] .tile{filter:url(#cutout)} [data-skin=matisse] .layer{filter:url(#cutout) brightness(.88)}
[data-skin=matisse] svg .glyph{font-size:40px}

/* ---------- 10 · Isola (Finland): big bold blooms, black outlines, fresh pastels ---------- */
[data-skin=isola]{
  --bg:#ffffff; --card:#ffffff; --ink:#151515; --line:#e8e8e8; --soft:#f3f3f3; --accent:#a8e6cf;
  --g0:#f7a1a1; --g1:#ffe27a; --g2:#a6d8f5; --g3:#a8e6cf; --g4:#ffc8a2; --g5:#d5c6f0;
  --i0:#151515; --i1:#151515; --i2:#151515; --i3:#151515; --i4:#151515; --i5:#151515;
  --c0:#c8323d; --c1:#156fb0; --c2:#9a6200; --c3:#8857c8; --c4:#0d7a5e;
  --ca:#ffffff; --cb:#f6f6f6; --boxline:#151515; --tstroke:#151515; --tsw:3px;
  --font-head:"Space Grotesk",sans-serif; --font-glyph:"Space Grotesk",sans-serif; --glyph-weight:700; --coach:#151515;
}
[data-skin=isola] .tile .rd,[data-skin=isola] .layer .rd{display:none}
[data-skin=isola] .tile .ci,[data-skin=isola] .layer .ci{display:inline}

/* ---------- 0 · Maiolica: the original, cobalt ink and glazed tiles ---------- */
[data-skin=maiolica]{
  --bg:#f6eedc; --card:#fffaf0; --ink:#1b2a41; --muted:#6c6450; --line:#e2d5b8; --soft:#efe3c6; --accent:#1b2a41; --accent-ink:#fffaf0;
  --g0:#2f5d9e; --g1:#b8492f; --g2:#e9b52f; --g3:#5a7224; --g4:#237a74; --g5:#7d3c6b;
  --i0:#fff; --i1:#fff; --i2:#3a2a06; --i3:#fff; --i4:#fff; --i5:#fff;
  --c0:#d6246e; --c1:#1b2a41; --c2:#b84800; --c3:#5a189a; --c4:#0b6e4f;
  --frame:#1b2a41; --ca:#fffaf0; --cb:#f4e9cf; --boxline:#1b2a41; --tstroke:#1b2a41; --tsw:2.5px; --shine:.2;
  --font-head:"Playfair Display",Georgia,serif; --font-body:Karla,sans-serif; --font-glyph:"Playfair Display",Georgia,serif;
  --glyph-weight:900; --border:2px; --shadow:6px 6px 0 #1b2a41; --btn-shadow:2px 2px 0 #1b2a41; --coach:#1b2a41; --hl:#fde7a6;
}
[data-skin=maiolica] .gv{display:inline;stroke:#fff;stroke-opacity:.75;stroke-dasharray:none} [data-skin=maiolica] .gvc{display:none}
[data-skin=maiolica] .stage,[data-skin=maiolica] .clue,[data-skin=maiolica] .rules div{border-color:#1b2a41}
</style>
"""
