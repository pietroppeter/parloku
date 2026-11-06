// Pietro (2026-11-06), ESTATE · MARE · SERATA: moving SERATA's last A far up to the right took it off the board,
// because the finger crossed the T before it. Build index.html first, serve the repo on :8765, then: node tests/gestures/head.js
const { chromium, devices } = require('playwright');
(async () => {
  const b = await chromium.launch();
  const p = await (await b.newContext({ ...devices['iPhone 13'], locale: 'it-IT' })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  const g = 'M0,A1,S2,T6,R7,E8,A12,M14,S18,E19,R20,A21,T22,M23,E24,S25,T26,M27,A28,R29,R30,M31,A32,T33,E34,S35'.split(',').map(s => s.slice(1) + s[0]).join(',');
  await p.goto('http://localhost:8765/index.html?nosplash&demo&p=AEMRST_21T_40ESTATE.00MARE.30SERATA&g=' + g);
  await p.waitForTimeout(1000);
  const cellXY = async c => { const bb = await (await p.$('#board svg')).boundingBox();
    return [bb.x + bb.width * (66 + (c % 6) * 78 + 39 - 50) / 500, bb.y + bb.height * (16 + Math.floor(c / 6) * 78 + 39) / 664]; };
  const board = () => p.evaluate(() => { const g = Array(36).fill('.');
    const bb = document.querySelector('#board svg').getBoundingClientRect();
    for (const e of document.querySelectorAll('#board .fg .item')) { const r = e.getBoundingClientRect();
      const x = (r.left + r.width/2 - bb.left) / bb.width * 500 + 50 - 66, y = (r.top + r.height/2 - bb.top) / bb.height * 664 - 16;
      const c = Math.floor(x / 78), rr = Math.floor(y / 78); if (c >= 0 && c < 6 && rr >= 0 && rr < 6) g[rr*6+c] = e.textContent.trim()[0]; }
    return [0,1,2,3,4,5].map(r => g.slice(r*6, r*6+6).join(' ')).join('\n'); });
  console.log(await board());
  const [x0, y0] = await cellXY(28), [x1, y1] = await cellXY(11);
  await p.mouse.move(x0, y0); await p.mouse.down();
  for (let i = 1; i <= 20; i++) { await p.mouse.move(x0 + (x1 - x0) * i / 20 + (process.argv[2] ? 0 : 0), y0 + (y1 - y0) * i / 20); await p.waitForTimeout(16); }
  await p.mouse.up(); await p.waitForTimeout(600);
  console.log('after dragging the A from r5c5 over the T to r2c6 (the A moves):\n' + await board());
  const drag = async (cs) => { const xy = []; for (const c of cs) xy.push(await cellXY(c));
    await p.mouse.move(...xy[0]); await p.mouse.down();
    for (let k = 1; k < xy.length; k++) for (let i = 1; i <= 10; i++) { await p.mouse.move(xy[k-1][0] + (xy[k][0] - xy[k-1][0]) * i / 10, xy[k-1][1] + (xy[k][1] - xy[k-1][1]) * i / 10); await p.waitForTimeout(16); }
    await p.mouse.up(); await p.waitForTimeout(600); };
  await p.goto(p.url()); await p.waitForTimeout(1000);
  await drag([28, 22]);
  console.log('let go on the T before it (the A goes below):\n' + await board());
  console.log('errors', errs);
  await b.close();
})();
