## The daily splash screen and the animated first lesson.
## Game mode only: the overlay lives outside the `.game` slice the devlog posts embed, and its script tag
## carries an id so `slice(built, "<script>", ...)` keeps picking the game script.
## Plain JS for now (it is a prototype of an idea); it reads the page's language from <html lang>
## and uses the skins' CSS variables, so it follows EN/IT and every skin.
##
## URL switches: `?splash=first` shows the first-visit splash again, `?learn` opens the lesson directly,
## `?nosplash` skips it (and so does `?tutorial`).
import std/json

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
.sp-lang{display:flex;gap:4px}
.sp-lang button,.sp-x{font:700 12px var(--font-body);border:1.5px solid var(--line);background:var(--card);color:var(--muted);border-radius:999px;padding:3px 9px;cursor:pointer}
.sp-lang button.on{border-color:var(--ink);color:var(--ink)}
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
.tu-grid .ca{fill:var(--ca)} .tu-grid .cb{fill:var(--cb)}
.tu-grid .thin{stroke:var(--line);stroke-width:.02}
.tu-grid .thick{stroke:var(--boxline);stroke-width:.05;fill:none}
.tu-hl{fill:var(--hl);opacity:0;transition:opacity .4s}
.tu-hl.on{opacity:.9}
.tu-stage svg.tu-over{z-index:3}
.tu-path{fill:none;stroke-width:.1;stroke-linecap:round;stroke-linejoin:round;stroke-dasharray:1;stroke-dashoffset:1;opacity:.6}
.tu-path.on{transition:stroke-dashoffset 1.6s ease-in-out;stroke-dashoffset:0}
.tu-t{position:absolute;left:0;top:0;width:calc(var(--c) * .86);height:calc(var(--c) * .86);border-radius:22%;
  display:grid;place-items:center;font:var(--glyph-weight) calc(var(--c) * .5)/1 var(--font-glyph);
  background:var(--card);color:var(--ink);box-shadow:inset 0 0 0 1.5px var(--line);
  transform:translate(calc(var(--x) * var(--c)), calc(var(--y) * var(--c))) scale(var(--s,1));
  transition:transform .6s cubic-bezier(.3,1.25,.5,1),opacity .4s,background .35s,color .35s,box-shadow .35s}
.tu-t.col{box-shadow:inset 0 0 0 var(--tsw) var(--tstroke)}
.tu-t.ghost{opacity:0}
.tu-t.bump{animation:tu-bump .45s}
@keyframes tu-bump{40%{transform:translate(calc(var(--x) * var(--c)), calc(var(--y) * var(--c))) scale(1.18)}}
.tu-t.dim{opacity:.3}
.tu-n{position:absolute;left:0;top:0;width:var(--c);height:var(--c);border-radius:26%;border:calc(var(--c) * .07) solid;z-index:2;pointer-events:none;
  transform:translate(calc(var(--x) * var(--c)), calc(var(--y) * var(--c)));opacity:0;transition:opacity .4s}
.tu-n.on{opacity:1}
.tu-text{min-height:5.4em;margin:12px 2px 10px;font-size:16.5px;line-height:1.45;text-align:left}
.tu-text b{font-family:var(--font-glyph);letter-spacing:.04em}
.tu-text p{margin:0 0 6px}
.tu-text p.in{animation:tu-in .45s both}
@keyframes tu-in{from{opacity:0;transform:translateY(6px)}}
.tu-acts{display:flex;gap:8px;justify-content:flex-end;flex-wrap:wrap;min-height:44px}
.tu-acts.col{flex-direction:column;align-items:stretch}
.tu-acts.col .sp-btn{text-align:left}
@media (prefers-reduced-motion:reduce){.tu-t,.tu-path.on,.sp-logo i{transition-duration:.01s!important;animation-duration:.01s!important}}
</style>
"""

const splashJs = """
(() => {
const D = window.PARLOKU_SPLASH;
const $ = id => document.getElementById(id);
const lang = () => (document.documentElement.lang === 'it' ? 'it' : 'en');
const T = (en, it) => (lang() === 'it' ? it : en);
const ls = {
  get: k => { try { return localStorage.getItem(k) } catch (e) { return null } },
  set: (k, v) => { try { localStorage.setItem(k, v) } catch (e) {} },
};
const reduced = matchMedia('(prefers-reduced-motion: reduce)').matches;
const q = String(location.search);
let root, card, timer = 0, run = 0;

// ---------- the daily splash
const LINES = [
  ["Six letters are waiting for you, and they're in no hurry.", "Sei lettere ti aspettano, e non hanno fretta."],
  ["The words are hiding well today. Seek better.", "Oggi le parole si nascondono bene. Tu cercale meglio."],
  ["A coffee, a grid, six letters.", "Un caffè, una griglia, sei lettere."],
  ["No letter repeats itself, not even on a {day}.", "Nessuna lettera si ripete, nemmeno di {day}."],
  ["Thirty-six cells, zero rush.", "Trentasei caselle, zero fretta."],
  ["The tiles are polished and ready.", "Le tessere sono lucidate e pronte."],
  ["Thought of the day: every word has a beginning.", "Pensiero del giorno: ogni parola ha un inizio."],
  ["Six rows, six columns, six boxes. And one smile.", "Sei righe, sei colonne, sei riquadri. E un sorriso."],
  ["The little sudoku that thinks in words.", "Il sudoku piccolo che pensa a parole."],
  ["First the first letter. The rest follows.", "Prima la prima lettera. Il resto viene da sé."],
  ["Breathe. Drag. Repeat.", "Respira. Trascina. Ripeti."],
  ["A grid a day keeps the boredom away.", "Una griglia al giorno toglie la noia di torno."],
  ["No numbers today: letters only, promise.", "Oggi niente numeri: solo lettere, promesso."],
  ["Every cell knows what it wants. Just ask it nicely.", "Ogni casella sa già cosa vuole. Basta chiederglielo con gentilezza."],
  ["A perfect {day} for six letters.", "Un {day} perfetto per sei lettere."],
  ["Small grid, big satisfaction.", "Piccola griglia, grande soddisfazione."],
  ["Mistakes are allowed: there's an undo button.", "Sbagliare si può: c'è il tasto annulla."],
  ["Words are clues in disguise.", "Le parole sono indizi travestiti."],
  ["Six colours, six letters, one solution.", "Sei colori, sei lettere, una sola soluzione."],
  ["Today's letters stretched and warmed up.", "Le lettere di oggi hanno fatto stretching."],
  ["Up, down, left, right. Never diagonal.", "Su, giù, destra, sinistra. Mai in diagonale."],
];
const SPECIAL = {  // MM-DD
  '01-01': ["Happy new year! New grid, same six letters.", "Buon anno! Griglia nuova, sei lettere di sempre."],
  '10-31': ["Boo! Even the letters are in costume.", "Bu! Anche le lettere sono in maschera."],
  '12-25': ["Merry Christmas! Six letters under the tree.", "Buon Natale! Sei lettere sotto l'albero."],
};
function today() {
  const m = q.match(/day=(\d{4})-(\d\d)-(\d\d)/);    // ?day=2026-12-25 previews another day
  return m ? new Date(+m[1], +m[2] - 1, +m[3], new Date().getHours()) : new Date();
}
function hello(d) {
  const h = d.getHours();
  if (h >= 5 && h < 12) return T('Good morning!', 'Buongiorno!');
  if (h >= 12 && h < 18) return T('Good afternoon!', 'Buon pomeriggio!');
  if (h >= 18 && h < 23) return T('Good evening!', 'Buonasera!');
  return T('Hello, night owl!', 'Ciao, nottambulo!');
}
function lineOf(d) {
  const key = String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
  const n = Math.floor(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()) / 864e5);
  const pair = SPECIAL[key] || LINES[n % LINES.length];
  const day = d.toLocaleDateString(lang() === 'it' ? 'it-IT' : 'en-GB', {weekday: 'long'});
  return pair[lang() === 'it' ? 1 : 0].replace('{day}', day);
}
function logo() {
  return [...'PARLOKU'].map((ch, i) =>
    `<i style="background:var(--g${i % 6});color:var(--i${i % 6});animation-delay:${0.15 + i * 0.07}s">${ch}</i>`).join('');
}
function langSwitch() {
  return `<div class="sp-lang">${['en', 'it'].map(l =>
    `<button data-lang="${l}" class="${l === lang() ? 'on' : ''}">${l.toUpperCase()}</button>`).join('')}</div>`;
}
function setLang(l) {
  const b = document.querySelector(`#langs [data-lang="${l}"]`);   // the game's own switch, so it re-renders too
  if (b) b.click(); else document.documentElement.lang = l;
}

function open() {
  root.hidden = false;
  document.body.style.overflow = 'hidden';
  requestAnimationFrame(() => root.classList.add('in'));
}
function close() {
  clearTimeout(timer);
  run++;
  ls.set('parloku:seen', '1');
  root.classList.remove('in');
  document.body.style.overflow = '';
  setTimeout(() => { root.hidden = true; card.innerHTML = '' }, 350);
}

function splash(first) {
  clearTimeout(timer);
  const d = today();
  const date = d.toLocaleDateString(lang() === 'it' ? 'it-IT' : 'en-GB', {weekday: 'long', day: 'numeric', month: 'long'});
  const stay = 3200;
  card.innerHTML = `
    <div class="sp-top"><span class="sp-date">${date}</span>${langSwitch()}</div>
    <div class="sp-hello">${hello(d)}</div>
    <p class="sp-line">${lineOf(d)}</p>
    <div class="sp-logo">${logo()}</div>
    <p class="sp-what">${T('a mini sudoku with words', 'un mini sudoku con parole')}</p>
    ${first
      ? `<p class="sp-first">${T('First time here?', 'È la prima volta qui?')}</p>
         <div class="sp-acts"><button class="sp-btn main" data-go="learn">${T('How do I play? 👀', 'Come si gioca? 👀')}</button>
         <button class="sp-btn" data-go="play">${T("I know it, let's play", 'Lo conosco, si gioca')}</button></div>`
      : `<div class="sp-acts"><button class="sp-btn main" data-go="play">${T('Play ▸', 'Gioca ▸')}</button>
         <button class="sp-btn link" data-go="learn">${T('how do I play?', 'come si gioca?')}</button></div>
         <div class="sp-bar"><i style="animation-duration:${stay}ms"></i></div>`}`;
  card.onclick = ev => {
    const l = ev.target.closest('[data-lang]');
    if (l) { setLang(l.dataset.lang); splash(true); return }   // after a language change, wait for a choice
    const go = ev.target.closest('[data-go]');
    if (!go) return;
    if (go.dataset.go === 'learn') lesson(); else close();
  };
  if (!first) timer = setTimeout(close, stay);
}

// ---------- the lesson
const L = D.letters, SOL = D.solution;
const li = ch => L.indexOf(ch);
function pathOf(word, start) {    // the walk that spells `word` in the solution, from `start`
  const out = [];
  const go = (c, i) => {
    if (SOL[c] !== word[i] || out.includes(c)) return false;
    out.push(c);
    if (i === word.length - 1) return true;
    const r = Math.floor(c / 6), k = c % 6;
    for (const n of [r > 0 && c - 6, r < 5 && c + 6, k > 0 && c - 1, k < 5 && c + 1])
      if (n !== false && go(n, i + 1)) return true;
    out.pop();
    return false;
  };
  go(start, 0);
  return out;
}
const CLUES = D.clues.map(c => ({...c, path: pathOf(c.word, c.r * 6 + c.c)}));

let stage, svg, texts, acts, dots, chips, trayT, cellT, nums, C = 40;
const sleep = ms => new Promise((ok, no) => { const me = run; setTimeout(() => (me === run ? ok() : no('stop')), reduced ? Math.min(ms, 60) : ms) });
const frame = () => new Promise(ok => requestAnimationFrame(() => requestAnimationFrame(ok)));
function mk(cls, html, parent = stage) {
  const e = document.createElement('div');
  e.className = cls;
  if (html !== undefined) e.innerHTML = html;
  parent.appendChild(e);
  return e;
}
function at(e, x, y) { e.style.setProperty('--x', x); e.style.setProperty('--y', y) }
function colour(e, ch) {
  const i = li(ch);
  e.classList.add('col');
  e.style.background = `var(--g${i})`;
  e.style.color = `var(--i${i})`;
}
const cellXY = c => [c % 6 + 0.07, Math.floor(c / 6) + 0.07];
const trayXY = i => [i + 0.07, 6.4];
function say(html, step) {
  texts.innerHTML = html.split('\n').map(s => `<p class="in">${s}</p>`).join('');
  [...dots.children].forEach((d, i) => d.classList.toggle('on', i <= step));
}
function ask(buttons, column) {   // [[label, value, main?]] -> the value clicked
  acts.className = 'tu-acts' + (column ? ' col' : '');
  return new Promise(ok => {
    acts.innerHTML = buttons.map(([t, v, m]) => `<button class="sp-btn${m ? ' main' : ''}" data-v="${v}">${t}</button>`).join('');
    acts.onclick = ev => {
      const b = ev.target.closest('[data-v]');
      if (b) { acts.innerHTML = ''; ok(b.dataset.v) }
    };
  });
}
const next = () => ask([[T('next →', 'avanti →'), 'next', true]]);

function gridSvg() {
  let s = '<g class="tu-grid">';
  for (let c = 0; c < 36; c++) {
    const r = Math.floor(c / 6), k = c % 6;
    s += `<rect class="${(Math.floor(r / 2) + Math.floor(k / 3)) % 2 ? 'cb' : 'ca'} thin" x="${k}" y="${r}" width="1" height="1"/>`;
  }
  s += '<rect class="tu-hl" id="tu-hl" x="0" y="0" width="0" height="0"/>';
  s += '<path class="thick" d="M0 0H6V6H0Z M3 0V6 M0 2H6 M0 4H6"/></g>';
  return s;
}
function highlight(x, y, w, h) {
  const r = svg.querySelector('#tu-hl');
  if (!w) { r.classList.remove('on'); return }
  Object.entries({x, y, width: w, height: h}).forEach(([k, v]) => r.setAttribute(k, v));
  r.classList.add('on');
}
async function fly(cells, gap) {   // tiles of the solution fly from the tray into `cells`
  for (const c of cells) {
    if (cellT[c]) continue;
    const ch = SOL[c];
    const t = mk('tu-t', ch);
    colour(t, ch);
    at(t, ...trayXY(li(ch)));
    cellT[c] = t;
    await frame();
    at(t, ...cellXY(c));
    await sleep(gap);
  }
}
const ROW = r => [0, 1, 2, 3, 4, 5].map(k => r * 6 + k);
const COL = k => [0, 1, 2, 3, 4, 5].map(r => r * 6 + k);
const BOX = b => [0, 1, 2, 3, 4, 5].map(i => (Math.floor(b / 2) * 2 + Math.floor(i / 3)) * 6 + (b % 2) * 3 + i % 3);
const ALL = [...Array(36).keys()];

async function lesson() {
  clearTimeout(timer);
  const me = ++run;
  ls.set('parloku:seen', '1');
  card.onclick = null;
  card.innerHTML = `<div class="tu-head"><div class="tu-dots">${'<i></i>'.repeat(6)}</div>
    <button class="sp-x" id="tu-skip">${T('skip ✕', 'salta ✕')}</button></div>
    <div class="tu-stage" id="tu-stage"><svg viewBox="0 0 6 7.35">${gridSvg()}</svg><svg class="tu-over" viewBox="0 0 6 7.35"><g id="tu-paths"></g></svg></div>
    <div class="tu-text" id="tu-text"></div><div class="tu-acts" id="tu-acts"></div>`;
  stage = $('tu-stage'); svg = stage.querySelector('svg'); texts = $('tu-text'); acts = $('tu-acts');
  dots = card.querySelector('.tu-dots');
  $('tu-skip').onclick = () => close();
  const size = () => { C = stage.clientWidth / 6; stage.style.setProperty('--c', C + 'px'); stage.style.height = 7.35 * C + 'px' };
  size();
  window.onresize = size;
  chips = []; cellT = {}; trayT = []; nums = [];
  try { await play() } catch (e) { if (e !== 'stop') throw e }
  if (me === run) window.onresize = null;
}

async function play() {
  // 1 · three words
  say(T('Here are three words.', 'Ecco tre parole.'), 0);
  for (const [w, word] of CLUES.map(c => c.word).entries()) {
    const x0 = (6 - word.length) / 2 + 0.07;
    for (const [i, ch] of [...word].entries()) {
      const t = mk('tu-t ghost', ch);
      t.dataset.ch = ch;
      at(t, x0 + i, 0.6 + w * 1.3 + 0.4);
      chips.push(t);
      await frame();
      t.classList.remove('ghost');
      at(t, x0 + i, 0.6 + w * 1.3);
      await sleep(70);
    }
    await sleep(380);
  }
  say(T(`<b>${CLUES.map(c => c.word).join(', ')}</b>. Look closely at their letters…`,
        `<b>${CLUES.map(c => c.word).join(', ')}</b>. Guarda bene le loro lettere…`), 0);
  await next();

  // 2 · the same six letters
  for (const t of chips) { colour(t, t.dataset.ch); await sleep(45) }
  say(T(`They are all made of the same <b>six letters</b>: ${L.split('').join(' ')}.`,
        `Sono fatte tutte delle stesse <b>sei lettere</b>: ${L.split('').join(' ')}.`), 1);
  await sleep(900);
  const keep = {};
  for (const t of chips) {
    const ch = t.dataset.ch;
    at(t, ...trayXY(li(ch)));
    if (keep[ch]) setTimeout(() => t.classList.add('ghost'), 600); else keep[ch] = t;
    await sleep(55);
  }
  await sleep(700);
  trayT = [...L].map(ch => keep[ch]);
  say(T('One copy of each goes down here: these are our <b>six symbols</b>.\nSix different symbols are just what a <b>mini sudoku</b> needs.',
        'Una copia di ognuna si mette giù: sono i nostri <b>sei simboli</b>.\nSei simboli diversi sono proprio quelli che servono a un <b>mini sudoku</b>.'), 1);
  await next();

  // 3 · do you know the mini sudoku?
  say(T('Do you know what a mini sudoku is?', 'Sai cos’è un mini sudoku?'), 2);
  const level = await ask([
    [T("No, what's a sudoku?", 'No, cos’è un sudoku?'), 'new'],
    [T('I know sudoku, not the mini one', 'Conosco il sudoku, non il mini'), 'sudoku'],
    [T('Yes, I know it', 'Sì, lo conosco'), 'mini', true]], true);
  svg.querySelector('.tu-grid').classList.add('on');

  if (level === 'new') {
    say(T('A mini sudoku is a 6×6 grid: 36 cells.\nThe game is to fill every cell with one of the six symbols.',
          'Un mini sudoku è una griglia 6×6: 36 caselle.\nIl gioco è riempire ogni casella con uno dei sei simboli.'), 3);
    await sleep(600); await next();
    highlight(0, 0, 6, 1);
    say(T('<b>Rule 1.</b> Every row has each symbol exactly once.', '<b>Regola 1.</b> In ogni riga c’è ogni simbolo, una volta sola.'), 3);
    await fly(ROW(0), 170); await next();
    highlight(0, 0, 1, 6);
    say(T('<b>Rule 2.</b> Same for every column.', '<b>Regola 2.</b> Lo stesso in ogni colonna.'), 3);
    await fly(COL(0), 170); await next();
    highlight(0, 0, 3, 2);
    say(T('<b>Rule 3.</b> Same for every 2×3 box, the ones with a thick border. There are six of them.',
          '<b>Regola 3.</b> Lo stesso in ogni riquadro 2×3, quelli con il bordo spesso. Ce ne sono sei.'), 3);
    await fly(BOX(0), 220); await next();
    highlight();
    say(T('No repeats in any row, column or box: that’s a solved mini sudoku.',
          'Nessun doppione in righe, colonne e riquadri: ecco un mini sudoku risolto.'), 3);
    await fly(ALL, 45); await sleep(500); await next();
  } else if (level === 'sudoku') {
    say(T('It’s a sudoku, only smaller: 6×6 instead of 9×9, boxes of 2×3, and six symbols instead of nine digits.',
          'È un sudoku, solo più piccolo: 6×6 invece di 9×9, riquadri di 2×3 e sei simboli invece di nove cifre.'), 3);
    for (const b of [0, 1, 2, 3, 4, 5]) { highlight((b % 2) * 3, Math.floor(b / 2) * 2, 3, 2); await sleep(420) }
    highlight();
    await next();
    say(T('Same rules: each symbol once in every row, column and box.',
          'Stesse regole: ogni simbolo una volta in ogni riga, colonna e riquadro.'), 3);
    await fly(ALL, 45); await sleep(500); await next();
  } else {
    say(T('Great. Then there is only one new thing.', 'Perfetto. Allora c’è una cosa sola di nuovo.'), 3);
    await fly(ALL, 35); await sleep(500);
  }

  // 4 · the words are in the grid
  say(T('Here the symbols are letters, and the three words are <b>hidden in the grid</b>.',
        'Qui i simboli sono lettere, e le tre parole sono <b>nascoste nella griglia</b>.'), 4);
  await sleep(level === 'mini' ? 900 : 300);
  const paths = stage.querySelector('#tu-paths');
  const lit = new Set();
  async function trace(i) {
    const c = CLUES[i];
    c.path.forEach(p => lit.add(p));
    for (const p of ALL) cellT[p].classList.toggle('dim', !lit.has(p));
    const n = mk('tu-n');
    n.style.borderColor = `var(--w${i % 3})`;
    at(n, c.c, c.r);
    nums.push(n);
    await frame(); n.classList.add('on');
    const d = c.path.map((p, k) => `${k ? 'L' : 'M'}${p % 6 + 0.5} ${Math.floor(p / 6) + 0.5}`).join(' ');
    paths.insertAdjacentHTML('beforeend', `<path class="tu-path" pathLength="1" d="${d}" style="stroke:var(--w${i % 3})"/>`);
    const el = paths.lastChild;
    await frame(); el.classList.add('on');
    for (const p of c.path) { const t = cellT[p]; t.classList.remove('bump'); void t.offsetWidth; t.classList.add('bump'); await sleep(1600 / c.path.length) }
  }
  await trace(0);
  say(T(`<b>${CLUES[0].word}</b> starts in the cell with its colour and goes one step at a time: up, down, left or right. Never diagonally.`,
        `<b>${CLUES[0].word}</b> parte dalla casella del suo colore e va avanti un passo alla volta: su, giù, a destra o a sinistra. Mai in diagonale.`), 4);
  await next();
  say(T(`Same for <b>${CLUES[1].word}</b> and <b>${CLUES[2].word}</b>, each from its own cell, each in its own colour.`,
        `Lo stesso per <b>${CLUES[1].word}</b> e <b>${CLUES[2].word}</b>, ognuna dalla sua casella, ognuna con il suo colore.`), 4);
  for (let i = 1; i < CLUES.length; i++) await trace(i);
  await next();

  // 5 · how a puzzle starts
  paths.innerHTML = '';
  for (const p of ALL) cellT[p].classList.remove('dim');
  for (const c of ALL) if (!D.givens.includes(c)) { at(cellT[c], ...trayXY(li(SOL[c]))); cellT[c].classList.add('ghost') }
  await sleep(700);
  say(T('A puzzle starts almost empty: a few letters, and for each word the coloured cell where it starts.\nThe words are clues: they tell you where letters go.',
        'Un puzzle parte quasi vuoto: qualche lettera e, per ogni parola, la casella colorata dove inizia.\nLe parole sono indizi: ti dicono dove vanno le lettere.'), 5);
  await next();
  say(T('To play, pull a copy out of a letter below the board and drop it on a cell. Want me to guide your first puzzle?',
        'Per giocare tira fuori una copia da una lettera sotto la griglia e lasciala su una casella. Vuoi che ti guidi nel primo puzzle?'), 5);
  const how = await ask([[T('Just play', 'Gioco da solo'), 'play'], [T('🎓 Guide me', '🎓 Guidami'), 'guide', true]]);
  ls.set('parloku:learned', '1');
  close();
  if (how === 'guide') { const b = $('tutorial'); if (b) b.click() }
}

// for pages that show it on demand (the devlog): parlokuSplash.splash(first), .lesson(), .lineFor(date)
window.parlokuSplash = {
  splash: first => { open(); splash(first) },
  lesson: () => { open(); lesson() },
  lineFor: d => lineOf(d),
};
document.addEventListener('DOMContentLoaded', () => {
  root = $('splash');
  if (!root) return;
  card = $('splash-card');
  root.addEventListener('click', ev => { if (ev.target === root && !card.querySelector('#tu-stage')) close() });
  if (root.dataset.manual !== undefined || q.includes('nosplash') || q.includes('tutorial')) return;
  open();
  if (q.includes('learn')) lesson();
  else splash(q.includes('splash=first') || !ls.get('parloku:seen'));
});
})();
"""

proc splashHtml*(letters, solution: string, givens: seq[int], clues: seq[(string, int, int)], auto = true): string =
  ## the overlay, its style and its script; `solution` is the 36 letters row by row.
  ## With `auto = false` nothing opens by itself: the page calls `parlokuSplash.splash(first)` or `.lesson()`.
  var cl = newJArray()
  for (w, r, c) in clues: cl.add %*{"word": w, "r": r, "c": c}
  let data = %*{"letters": letters, "solution": solution, "givens": givens, "clues": cl}
  let manual = if auto: "" else: " data-manual"
  splashCss & "<div class=\"sp\" id=\"splash\"" & manual & """ hidden role="dialog" aria-modal="true" aria-label="Parloku"><div class="sp-card" id="splash-card"></div></div>""" &
    "\n<script id=\"splash-js\">window.PARLOKU_SPLASH = " & $data & ";" & splashJs & "</script>\n"
