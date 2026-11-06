// The istruzioni page: under each gesture a practice board (the game in ?demo mode) where it can be tried.
// Build index.html and istruzioni.html first, then: node tests/gestures/istruzioni.js
const { chromium, devices } = require('playwright');
const os = require('os');
(async () => {
  const url = process.argv[2] || 'file://' + require('path').resolve(__dirname, '../../istruzioni.html');
  const b = await chromium.launch();
  const p = await (await b.newContext({ ...devices['iPhone 13'] })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto(url); await p.waitForTimeout(500);
  const frames = await p.$$('.try iframe');
  console.log('practice boards:', frames.length);
  // one board: scroll it into view, wait for its game, and drive it with the mouse in page coordinates
  async function board(i) {
    await frames[i].scrollIntoViewIfNeeded(); await p.waitForTimeout(1200);
    const f = await frames[i].contentFrame();
    const fb = await frames[i].boundingBox();
    const sb = await f.evaluate(() => { const r = document.querySelector('#board svg').getBoundingClientRect(); return { x: r.x, y: r.y, w: r.width, h: r.height }; });
    const xy = c => [fb.x + sb.x + sb.w * (66 + (c % 6) * 78 + 39 - 50) / 500, fb.y + sb.y + sb.h * (16 + Math.floor(c / 6) * 78 + 39) / 664];
    const at = c => f.evaluate(([x, y]) => { const e = document.elementFromPoint(x, y)?.closest('[data-key]'); return e ? e.querySelector('text').textContent : '-'; },
      [sb.x + sb.w * (66 + (c % 6) * 78 + 39 - 50) / 500, sb.y + sb.h * (16 + Math.floor(c / 6) * 78 + 39) / 664]);
    const row = async cs => (await Promise.all(cs.map(at))).join('');
    const dbl = async c => { await p.mouse.click(...xy(c)); await p.waitForTimeout(90); await p.mouse.click(...xy(c)); await p.waitForTimeout(500); };
    const walk = async cs => { await p.mouse.move(...xy(cs[0])); await p.mouse.down();
      for (const c of cs.slice(1)) { await p.mouse.move(...xy(c), { steps: 8 }); await p.waitForTimeout(60); } await p.mouse.up(); await p.waitForTimeout(500); };
    return { f, row, dbl, walk, menu: () => f.evaluate(() => document.body.className) };
  }
  let g = await board(3);
  console.log('word: before', await g.row([0, 1, 2]));
  await g.walk([0, 1, 2]);
  console.log('word: after dragging the I right twice', await g.row([0, 1, 2]), '(ITA)');
  g = await board(4);
  await g.dbl(20);
  console.log('remove: lone T at r4c3 gone:', await g.row([20]), '| ITALIA', await g.row([0, 1, 2]));
  await g.dbl(1);
  console.log('remove: double tap on the T of ITALIA cuts it there:', await g.row([0, 1, 2]), '(I--)');
  g = await board(5);
  await g.dbl(5);
  console.log('sure cell: r1c6 =', await g.row([5]), '(L)');
  await g.dbl(12);
  console.log('sure cell: green start r3c1 =', await g.row([12]), '(P)');
  await p.mouse.click(6, 30); await p.waitForTimeout(300);
  console.log('no menu inside a board:', await g.menu());
  await p.screenshot({ path: os.tmpdir() + '/istruzioni.png' });
  console.log('nothing saved:', await p.evaluate(() => Object.keys(localStorage).filter(k => k.startsWith('parloku:'))));
  console.log('errors', errs);
  await b.close();
})();
