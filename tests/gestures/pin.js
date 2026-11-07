// Pins and moving (change move-and-pin-tiles, Pietro 2026-11-07 after Emilia's playtest): a letter on the board moves,
// a long press pins it (📌) and a pinned letter gives copies, a finished word gives copies and has happy eyes.
// Build index.html first, then: node tests/gestures/pin.js
const { chromium, devices } = require('playwright');
const path = require('path');
(async () => {
  const b = await chromium.launch();
  const p = await (await b.newContext({ ...devices['iPhone 13'], locale: 'it-IT' })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  const page = 'file://' + path.resolve(__dirname, '../../index.html');
  const open = async g => { await p.goto(page + '?nosplash&demo&p=AILPST_51S.23L.04P_00ITALIA.20PASTA.40ALPI&g=' + g); await p.waitForTimeout(800); };
  const xy = async c => { const bb = await (await p.$('#board svg')).boundingBox();
    return [bb.x + bb.width * (66 + (c % 6) * 78 + 39 - 50) / 500, bb.y + bb.height * (16 + Math.floor(c / 6) * 78 + 39) / 664]; };
  const board = () => p.evaluate(() => { const g = Array(36).fill('.'), pins = [];
    const bb = document.querySelector('#board svg').getBoundingClientRect();
    for (const e of document.querySelectorAll('#board .fg .item')) { const r = e.getBoundingClientRect();
      const x = (r.left + r.width/2 - bb.left) / bb.width * 500 + 50 - 66, y = (r.top + r.height/2 - bb.top) / bb.height * 664 - 16;
      const c = Math.floor(x / 78), rr = Math.floor(y / 78);
      if (c >= 0 && c < 6 && rr >= 0 && rr < 6) { g[rr*6+c] = e.textContent.trim()[0]; if (e.querySelector('.pinmark')) pins.push(rr*6+c); } }
    return { grid: g.join(''), pins }; });
  const press = async (c, ms) => { await p.mouse.move(...await xy(c)); await p.mouse.down(); await p.waitForTimeout(ms); };
  const dragTo = async c => { const [x, y] = await xy(c); await p.mouse.move(x, y, { steps: 12 }); await p.mouse.up(); await p.waitForTimeout(500); };
  const long = async c => { await press(c, 700); await p.mouse.up(); await p.waitForTimeout(300); };
  let ok = true;
  const check = (what, cond) => { console.log((cond ? 'ok   ' : 'FAIL ') + what); ok = ok && cond; };

  await open('20T');
  await press(20, 0); await dragTo(26);
  let s = await board();
  check('a quick drag moves the T', s.grid[20] === '.' && s.grid[26] === 'T');
  await long(26);
  s = await board();
  check('a long press pins it', s.pins.join() === '26');
  await press(26, 0); await dragTo(28);
  s = await board();
  check('a pinned T gives a copy', s.grid[26] === 'T' && s.grid[28] === 'T' && s.pins.join() === '26');
  await long(26);
  s = await board();
  check('a second long press unpins', s.pins.length === 0);
  await press(28, 700); await dragTo(34);
  s = await board();
  check('hold then drag: pinned, and the copy goes', s.grid[28] === 'T' && s.grid[34] === 'T' && s.pins.join() === '28');

  // ITALIA one letter short, then finished: a hop, happy eyes, copies
  await open('0I,1T,2A,8L,9I');
  check('no happy eyes before', (await p.$$('#board .eye .happy')).length === 0);
  await press(9, 0); await dragTo(10);
  check('ITALIA finished: happy eyes', (await p.$$('#board .eye .happy')).length === 2);
  await press(1, 0); await dragTo(30);
  s = await board();
  check('a finished word gives copies', s.grid[1] === 'T' && s.grid[30] === 'T');
  check('no page errors', errs.length === 0);
  if (errs.length) console.log(errs);
  await b.close();
  process.exit(ok ? 0 : 1);
})();
