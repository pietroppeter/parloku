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
.clue .wring{flex:none;width:22px;height:22px;border-radius:50%;border:4px solid var(--wc);background:var(--card);cursor:grab;touch-action:none;margin-right:2px}
.clue .wring.on{background:color-mix(in srgb,var(--wc) 25%,var(--card))}
.ringghost{position:fixed;left:0;top:0;width:48px;height:48px;box-sizing:border-box;border-radius:50%;border:6px solid var(--wc);pointer-events:none;z-index:60}
.opt{fill:none;stroke-width:4;stroke-dasharray:7 6;animation:optp 1s ease-in-out infinite alternate}
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
.pm.on.w0{fill:var(--w0)} .pm.on.w1{fill:var(--w1)} .pm.on.w2{fill:var(--w2)}
.status .acts{align-items:center}
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
.sol{font:600 14px var(--font-body);color:var(--muted);margin-left:10px}
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
</style>
"""
