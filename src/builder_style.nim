## Extra CSS for the builder page, on top of `style.nim` (the builder uses the game's Niki skin).
const builderCss* = """
<style>
html{-webkit-text-size-adjust:100%;text-size-adjust:100%}
.bld h1 .sub{font-size:.42em;color:var(--muted);font-weight:600;letter-spacing:.02em}
.sets{display:flex;gap:8px;overflow-x:auto;padding:4px 2px 8px;margin:6px -16px 0;padding-left:16px;scrollbar-width:none}
.sets::-webkit-scrollbar{display:none}
.sets .btn{flex:none}
.row.custom{display:flex;gap:8px;margin:4px 0 8px}
.row.custom input{flex:1;min-width:0;font:600 15px var(--font-body);padding:8px 12px;border:2px solid var(--ink);border-radius:999px;background:var(--card);color:var(--ink);text-transform:uppercase}
.say{min-height:24px;font-size:15px;color:var(--muted);margin:4px 0 4px}
.clue{cursor:pointer}
/* words sit on the left, each after its ring: drag the ring onto the board to start the word */
.bld .clue,.bld .clue:nth-child(3n+2),.bld .clue:nth-child(3n){align-self:flex-start}
.clue .wring{flex:none;width:22px;height:22px;border-radius:7px;border:4px solid var(--wc);background:var(--card);cursor:grab;touch-action:none;margin-right:2px}
.clue .wring.on{background:color-mix(in srgb,var(--wc) 25%,var(--card))}
.ringghost{position:fixed;left:0;top:0;width:48px;height:48px;box-sizing:border-box;border-radius:13px;border:5px solid var(--wc);pointer-events:none;z-index:60}
.opt{fill:none;stroke-width:4;animation:optp 1s ease-in-out infinite alternate}
.opt.w0{stroke:var(--w0)} .opt.w1{stroke:var(--w1)} .opt.w2{stroke:var(--w2)}
@keyframes optp{from{opacity:.45}to{opacity:1}}
.bld,.bld *{-webkit-touch-callout:none;-webkit-user-select:none;user-select:none;-webkit-tap-highlight-color:transparent}
.bld input{-webkit-user-select:text;user-select:text}
.bld .stage{touch-action:none}
.jig.j0{animation:jig0 .28s ease-in-out infinite alternate} .jig.j1{animation:jig1 .28s ease-in-out infinite alternate}
.jig.lift{filter:drop-shadow(0 8px 8px rgba(0,0,0,.25))}
@keyframes jig0{from{transform:rotate(-4deg)}to{transform:rotate(4deg)}}
@keyframes jig1{from{transform:rotate(4deg)}to{transform:rotate(-4deg)}}
.growtile circle{stroke:var(--tstroke);stroke-width:var(--tsw)}
.growtile{pointer-events:none;filter:drop-shadow(0 6px 6px rgba(0,0,0,.2))}
/* pencil marks in the empty cells */
.pm{font:700 15px "JetBrains Mono",monospace;fill:color-mix(in srgb,var(--ink) 50%,transparent);pointer-events:none}
.dragging .pm{opacity:.5}
.pm.on{font-weight:800;font-size:17px}
.pm.on.w0{fill:var(--w0)} .pm.on.w1{fill:var(--w1)} .pm.on.w2{fill:var(--w2)} .pm.on.sk{fill:var(--ink)}
.status .acts{align-items:center}
.nou{font:600 13px var(--font-body);color:var(--muted);margin-left:8px;display:inline-flex;align-items:center;gap:3px;white-space:nowrap}
.tool.dice{width:38px;height:38px;font-size:18px;margin-left:6px}
.tool:disabled{opacity:.35;cursor:default}
/* words on the left, four round tools in a square on the right */
.bld .top{display:flex;align-items:center;gap:10px}
.bld .top .clues{flex:1;min-width:0}
.tools{display:grid;grid-template-columns:repeat(2,44px);gap:8px;flex:none}
.tool{width:44px;height:44px;border-radius:50%;border:var(--border) solid var(--ink);background:var(--card);display:grid;place-items:center;
  font-size:20px;line-height:1;padding:0;cursor:pointer;color:var(--ink);font-family:inherit}
.tool.pinsrc{background:var(--hl);cursor:grab;touch-action:none;user-select:none;-webkit-user-select:none}
.pinghost{font-size:34px;line-height:52px;text-align:center}
/* the pin: drag it from the bar onto a letter; pinned tiles wear a small one in the corner */
svg.pin line{stroke:var(--ink);stroke-width:3;stroke-linecap:round}
svg.pin circle{fill:var(--w0);stroke:var(--ink);stroke-width:2.5}
svg.pin circle.hi{fill:rgba(255,255,255,.65);stroke:none}
.pinghost{position:fixed;left:0;top:0;width:36px;height:52px;pointer-events:none;z-index:60;filter:drop-shadow(0 6px 6px rgba(0,0,0,.25))}
.pinghost svg{width:100%;height:100%}
.pinmark line{stroke:var(--ink);stroke-width:2.5;stroke-linecap:round}
.pinmark circle{fill:var(--w0);stroke:var(--ink);stroke-width:2}
/* a tapped word's outline wiggles */
.wig{animation:wig .65s ease-in-out}
@keyframes wig{0%,100%{transform:none}15%{transform:rotate(-5deg) scale(1.04)}35%{transform:rotate(4deg) scale(1.04)}55%{transform:rotate(-3deg)}75%{transform:rotate(2deg)}}
@media (prefers-reduced-motion: reduce){.wig{animation:none}}
.sol{font:600 13px var(--font-body);color:var(--muted);margin-left:8px}
.sol b{font:800 20px var(--font-head);color:var(--ink);margin-right:4px;vertical-align:-2px}
.sol.zero,.sol.zero b{color:var(--w0)}
.panel{margin:16px 0;padding:12px 14px;border:var(--border) solid var(--ink);border-radius:var(--radius);background:var(--card)}
.panel .verdict{font:600 16px var(--font-body);color:var(--muted)}
.panel .verdict b{font:800 34px var(--font-head);margin-right:6px;vertical-align:-4px;color:var(--ink)}
.panel .verdict.one b{color:var(--w1)} .panel .verdict.zero b{color:var(--w0)}
.panel .note{margin:2px 0 8px;font-size:14px;color:var(--muted)}
.panel .warn{margin:8px 0 0;font-size:14px;color:var(--w0)}
.panel .code code{display:block;font:13px "JetBrains Mono",monospace;background:var(--soft);padding:6px 10px;border-radius:8px;overflow-wrap:anywhere}
.panel .acts{display:flex;gap:8px;flex-wrap:wrap;margin-top:10px}
.panel a.btn{text-decoration:none}
.how{font-size:15px}
.how p{margin:8px 0}
pre > code{font-size:12.5px!important}
/* one compact screen: the bar of word sets, the words and tools, the board, one status line */
.bld{max-width:520px;margin:0 auto}
.bld .bar{display:flex;align-items:center;gap:6px;margin:2px 0 4px}
.bld .logo{flex:none;width:30px;height:30px;border-radius:8px;display:grid;place-items:center;font:800 20px var(--font-head);background:var(--c0,#7dc4ff);color:var(--ink);border:2px solid var(--ink)}
.bld .sets{flex:1;min-width:0;margin:0;padding:2px 0}
.bld .sets .btn{padding:4px 10px;font-size:12px}
.tool.sm{width:32px;height:32px;font-size:15px;text-decoration:none}
.bld .row.custom{margin:0 0 4px}
.bld .say{pointer-events:none;position:fixed;left:50%;top:8px;transform:translateX(-50%);z-index:70;max-width:min(92vw,480px);background:var(--ink);color:var(--card);
  font:600 13px/1.35 var(--font-body);padding:7px 12px;border-radius:12px;box-shadow:0 6px 18px rgba(0,0,0,.2);min-height:0;margin:0}
.bld .game{margin:0}
.bld .clues{gap:4px;margin:0}
.bld .clue{cursor:grab;touch-action:none;padding:2px 3px 2px 8px;gap:3px;border-width:2.5px}
.bld .clue .l{width:19px;height:23px;font-size:14px;border-radius:5px}
.bld .clue .wring{width:20px;height:20px;border-width:3.5px;margin:0 0 0 2px;position:relative}
.bld .clue .wring::after{content:'';position:absolute;inset:-11px -14px;border-radius:50%}
.bld .clue .ok:empty{display:none}
.bld .top{gap:6px}
.bld .tools{grid-template-columns:repeat(2,38px);gap:6px}
.bld .tool{width:38px;height:38px;font-size:17px}
.bld .stage{margin:4px auto 0;max-width:min(100%,calc((100svh - 272px) * 500 / 664));min-width:250px}
.bld .status{margin:2px 0 0;padding:0}
.bld .status .acts{gap:4px;flex-wrap:nowrap;justify-content:center}
.bld .status .btn{padding:4px 10px;font-size:13px}
.bld .tool.dice{width:32px;height:32px;font-size:16px;margin-left:2px}
.bld .panel{margin:6px 0 0;padding:6px 10px;display:flex;flex-wrap:wrap;align-items:center;gap:4px 10px;font-size:13px}
.bld .panel .verdict{font:600 13px var(--font-body)}
.bld .panel .verdict b{font:800 20px var(--font-head);margin-right:3px;vertical-align:-2px}
.bld .panel .note{margin:0;font-size:12px}
.bld .panel .warn{margin:0;font-size:12px;flex-basis:100%}
.bld .btn.sm{padding:3px 10px;font-size:12px;text-decoration:none}
.bld ~ *, footer, body > hr{display:none}
body:has(.bld) main{padding-top:6px!important;padding-bottom:0!important;margin-top:0!important;margin-bottom:0!important}
body:has(.bld){padding-top:0!important;padding-bottom:0!important}
/* no dashed lines in the builder */
.bld .clue .l{border-style:solid;border-color:color-mix(in srgb,var(--ink) 14%,transparent)}
.bld .empty,.bld .ghosts .target,.bld .ghosts .tether{stroke-dasharray:none}
.bld details{border-style:solid}
.jt .jig{pointer-events:none}
</style>
"""
