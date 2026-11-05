## Extra CSS for the builder page, on top of `style.nim` (the builder always uses the Niki skin).
const builderCss* = """
<style>
.bld h1 .sub{font-size:.42em;color:var(--muted);font-weight:600;letter-spacing:.02em}
.sets{display:flex;gap:8px;overflow-x:auto;padding:4px 2px 8px;margin:6px -16px 0;padding-left:16px;scrollbar-width:none}
.sets::-webkit-scrollbar{display:none}
.sets .btn{flex:none}
.row.custom{display:flex;gap:8px;margin:4px 0 8px}
.row.custom input{flex:1;min-width:0;font:600 15px var(--font-body);padding:8px 12px;border:2px solid var(--ink);border-radius:999px;background:var(--card);color:var(--ink);text-transform:uppercase}
.say{min-height:24px;font-size:15px;color:var(--muted);margin:4px 0 8px}
.words{display:flex;flex-direction:column;gap:8px;margin:0 0 12px}
.wchip{display:flex;align-items:center;gap:4px;align-self:flex-start;padding:5px 8px;border:3px solid currentColor;border-radius:var(--radius);
  background:var(--card);cursor:pointer;user-select:none;-webkit-user-select:none}
.wchip:nth-child(3n+2){align-self:center} .wchip:nth-child(3n){align-self:flex-end}
.wchip.w0{color:var(--w0)} .wchip.w1{color:var(--w1)} .wchip.w2{color:var(--w2)}
.wchip.on{box-shadow:0 0 0 3px var(--accent),0 4px 12px rgba(0,0,0,.12)}
.wchip .l{width:24px;height:28px;border-radius:7px;display:grid;place-items:center;font:var(--glyph-weight) 17px var(--font-glyph);
  border:1.5px dashed var(--line);color:var(--muted)}
.wchip .l.in{border:1.5px solid var(--ink);color:var(--ink);background:var(--soft)}
.wchip.done .l.in{background:var(--hl)}
.wchip .mini{font:700 15px var(--font-body);border:2px solid currentColor;background:var(--card);color:inherit;border-radius:999px;
  width:32px;height:32px;margin-left:4px;cursor:pointer;padding:0}
.stage{padding:6px}
svg.board{display:block;width:100%;height:auto;touch-action:none;user-select:none;-webkit-user-select:none}
svg.board .boxlines line{stroke:var(--boxline);stroke-width:4;stroke-linecap:round}
svg.board .snake{fill:none;stroke-width:34;stroke-linecap:round;stroke-linejoin:round;opacity:.22}
svg.board .snake.on{opacity:.34}
svg.board .snake.w0{stroke:var(--w0)} svg.board .snake.w1{stroke:var(--w1)} svg.board .snake.w2{stroke:var(--w2)}
svg.board .start{fill:none;stroke-width:5}
svg.board .start.w0{stroke:var(--w0)} svg.board .start.w1{stroke:var(--w1)} svg.board .start.w2{stroke:var(--w2)}
.tb{stroke:var(--tstroke);stroke-width:var(--tsw)}
svg.board .pin{fill:var(--ink);stroke:var(--card);stroke-width:2}
svg.board .mark{font:700 17px "JetBrains Mono",monospace;fill:color-mix(in srgb,var(--ink) 55%,transparent)}
svg.board .forced{font-size:32px;fill:color-mix(in srgb,var(--ink) 45%,transparent)}
svg.board .none{font:800 34px var(--font-body);fill:var(--bad-line,#d33)}
svg.board .cell.tint{fill:var(--hl)}
svg.board .cell.bad{fill:var(--bad,#ffd3d3)}
.tray{display:grid;grid-template-columns:repeat(6,1fr);gap:6px;margin:12px 0 4px;touch-action:none}
.tray .ttile{width:100%;max-width:64px;justify-self:center;cursor:grab;overflow:visible}
.ghost{position:fixed;left:0;top:0;width:64px;height:64px;pointer-events:none;z-index:50;filter:drop-shadow(0 8px 8px rgba(0,0,0,.2))}
.ghost svg{width:100%;height:100%;overflow:visible}
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
html{-webkit-text-size-adjust:100%;text-size-adjust:100%}
.how p{margin:8px 0}
pre > code{font-size:12.5px!important}
</style>
"""
