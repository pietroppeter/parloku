## The daily splash screen and the animated first lesson.
## Game mode only: the overlay lives outside the `.game` slice the devlog posts embed.
## This file holds the markup and the style. The behaviour is Nim, in src/splashrt.nim, compiled into the
## game's script. It reads the page's language from <html lang> (Italian, or the English draft with ?lang=en)
## and uses the skins' CSS variables.
##
## URL switches: `?splash=first` shows the first-visit splash again, `?learn` opens the lesson directly,
## `?nosplash` skips it (and so does `?tutorial`).
import std/[strformat, strutils, sequtils]

const splashCss* = """
<style>
.sp{position:fixed;inset:0;z-index:60;display:flex;align-items:center;justify-content:center;padding:18px;
  background:color-mix(in srgb,var(--bg) 94%,transparent);backdrop-filter:blur(3px);-webkit-backdrop-filter:blur(3px);
  opacity:0;transition:opacity .35s}
.sp.in{opacity:1}
.sp-card{position:relative;width:min(100%,430px);max-height:100%;overflow:auto;background:var(--card);border:var(--border) solid var(--line);
  border-radius:calc(var(--radius) + 6px);box-shadow:var(--shadow),0 18px 50px rgba(0,0,0,.10);padding:22px 20px 18px;text-align:center}
.sp-top{display:flex;justify-content:space-between;align-items:center;gap:8px;margin:-6px -4px 6px}
.sp-date{font:700 12px "JetBrains Mono",monospace;letter-spacing:.12em;text-transform:uppercase;color:var(--muted)}
.sp-x{font:700 12px var(--font-body);border:1.5px solid var(--line);background:var(--card);color:var(--muted);border-radius:999px;padding:3px 9px;cursor:pointer}
.sp-hello{font:700 clamp(30px,8vw,40px)/1.05 var(--font-head);margin:14px 0 6px;color:var(--ink)}
.sp-line{font-size:17px;line-height:1.45;color:var(--ink);margin:0 auto 18px;max-width:30ch}
.sp-logo{display:flex;justify-content:center;gap:5px;margin:4px 0 6px}
.sp-logo i{font:var(--glyph-weight) 25px/40px var(--font-glyph);font-style:normal;width:40px;height:40px;border-radius:10px;
  box-shadow:inset 0 0 0 var(--tsw) var(--tstroke);opacity:0;transform:translateY(14px) scale(.6);animation:sp-pop .5s cubic-bezier(.3,1.5,.5,1) forwards}
@keyframes sp-pop{to{opacity:1;transform:none}}
.sp-what{font:600 15px var(--font-body);color:var(--muted);margin:0 0 18px}
.sp-first{font-size:15px;color:var(--muted);margin:0 0 8px}
.sp-acts{display:flex;gap:8px;justify-content:center;flex-wrap:wrap}
.sp-btn{font:700 15px var(--font-body);border:var(--border) solid var(--ink);background:var(--card);color:var(--ink);border-radius:999px;
  padding:10px 18px;min-height:44px;cursor:pointer;box-shadow:var(--btn-shadow)}
.sp-btn.main{background:var(--accent);color:var(--accent-ink)}
.sp-btn.link{border-color:transparent;background:none;box-shadow:none;text-decoration:underline;text-underline-offset:3px;color:var(--muted);font-weight:600}
.sp-btn:active{transform:translate(1px,1px)}
.sp-bar{height:3px;border-radius:3px;background:var(--line);margin:16px auto 0;width:60%;overflow:hidden}
.sp-bar i{display:block;height:100%;width:100%;background:var(--ink);transform-origin:left;animation:sp-bar linear forwards}
@keyframes sp-bar{from{transform:scaleX(0)}to{transform:scaleX(1)}}
/* the lesson */
.tu-head{display:flex;justify-content:space-between;align-items:center;margin:-6px -4px 8px}
.tu-dots{display:flex;gap:5px}
.tu-dots i{width:7px;height:7px;border-radius:50%;background:var(--line);transition:background .3s}
.tu-dots i.on{background:var(--ink)}
.tu-stage{position:relative;width:100%;margin:0 auto;touch-action:manipulation}
.tu-stage svg{position:absolute;left:0;top:0;width:100%;overflow:visible;pointer-events:none}
.tu-grid{opacity:0;transition:opacity .5s}
.tu-grid.on{opacity:1}
.tu-grid .thin{stroke:var(--line);stroke-width:.02;fill:none}
.tu-grid .thick{stroke:var(--boxline);stroke-width:.06;fill:none}
.tu-hl{fill:var(--hl);opacity:0;transition:opacity .4s}
.tu-hl.on{opacity:.9}
/* a word's outline, as in the game: a thin coloured band round its cells (an outer stroke, the card colour inside) */
.tu-path{fill:none;stroke-linecap:round;stroke-linejoin:round;stroke-dasharray:1;stroke-dashoffset:1}
.tu-path.out{stroke-width:.86} .tu-path.in{stroke-width:.76;stroke:var(--card)}
.tu-path.on{transition:stroke-dashoffset 1.6s ease-in-out;stroke-dashoffset:0}
.tu-t{position:absolute;left:0;top:0;width:calc(var(--c) * .86);height:calc(var(--c) * .86);border-radius:50%;
  display:grid;place-items:center;font:var(--glyph-weight) calc(var(--c) * .5)/1 var(--font-glyph);
  background:var(--card);color:var(--ink);box-shadow:inset 0 0 0 1.5px var(--line);
  transform:translate(calc(var(--x) * var(--c)), calc(var(--y) * var(--c))) scale(var(--s,1));
  transition:transform .6s cubic-bezier(.3,1.25,.5,1),opacity .4s,background .35s,color .35s,box-shadow .35s}
.tu-t.col{box-shadow:inset 0 0 0 var(--tsw) var(--tstroke)}
.tu-t.ghost{opacity:0}
.tu-t.bump{animation:tu-bump .45s}
@keyframes tu-bump{40%{transform:translate(calc(var(--x) * var(--c)), calc(var(--y) * var(--c))) scale(1.18)}}
.tu-t.dim{opacity:.3}
.tu-n{position:absolute;left:0;top:0;width:calc(var(--c) * .9);height:calc(var(--c) * .9);box-sizing:border-box;border-radius:24%;
  border:calc(var(--c) * .05) solid;z-index:2;pointer-events:none;
  transform:translate(calc((var(--x) + .05) * var(--c)), calc((var(--y) + .05) * var(--c)));opacity:0;transition:opacity .4s}
.tu-n.on{opacity:1}
.tu-text{min-height:5.4em;margin:12px 2px 10px;font-size:16.5px;line-height:1.45;text-align:left}
.tu-text b{font-family:var(--font-glyph);letter-spacing:.04em}
.tu-text p{margin:0 0 6px}
.tu-text p.in{animation:tu-in .45s both}
@keyframes tu-in{from{opacity:0;transform:translateY(6px)}}
.tu-acts{display:flex;gap:8px;justify-content:flex-end;flex-wrap:wrap;min-height:44px}
.tu-acts.col{flex-direction:column;align-items:stretch}
.tu-acts.col .sp-btn{text-align:left}
/* the finger that shows the gestures: the outer box moves, the inner dot presses (no var() inside the keyframes, for Safari) */
.tu-f{position:absolute;left:0;top:0;width:calc(var(--c) * .44);height:calc(var(--c) * .44);z-index:4;pointer-events:none;opacity:0;
  transform:translate(calc((var(--x) + .28) * var(--c)), calc((var(--y) + .28) * var(--c)));transition:transform .55s ease-in-out,opacity .3s}
.tu-f.on{opacity:1}
.tu-f i{display:block;width:100%;height:100%;border-radius:50%;background:rgba(40,40,40,.3);box-shadow:0 0 0 2px rgba(255,255,255,.85)}
.tu-f.tap i{animation:tu-tap .3s ease-out 2}
@keyframes tu-tap{50%{transform:scale(.6)}}
@media (prefers-reduced-motion:reduce){.tu-t,.tu-f,.tu-path.on,.sp-logo i{transition-duration:.01s!important;animation-duration:.01s!important}}
</style>
"""

proc splashHtml*(auto = true): string =
  ## the overlay and its style. The lesson brings its own example (src/splashrt.nim), so it spoils no puzzle.
  ## With `auto = false` nothing opens by itself: the page calls `parlokuSplash.splash(first)` or `.lesson()`.
  let manual = if auto: "" else: " data-manual"
  splashCss & &"""<div class="sp" id="splash"{manual} hidden role="dialog" aria-modal="true" aria-label="Parloku"><div class="sp-card" id="splash-card"></div></div><!-- /splash -->
"""
