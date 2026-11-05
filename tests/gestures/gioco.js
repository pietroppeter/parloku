// Pietro's GIOCO case: G-I-O-C, then dragging the C down must add the O (not read as GIOCO by stepping back). node tests/gestures/gioco.js
const { chromium, devices } = require('playwright');
(async () => {
  const b = await chromium.launch();
  const p = await (await b.newContext({ ...devices['iPhone 13'] })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto((process.argv[2] || 'file://' + require('path').resolve(__dirname, '../../index.html')) + '?nosplash&p=ACGIMO_41I.42O.54I.55O_00AMICA.11GIOCO.05MAGIA');
  await p.waitForTimeout(800);
  const bb = await (await p.$('#board svg')).boundingBox();
  const P = (x, y) => [bb.x + bb.width * (x - 50) / 500, bb.y + bb.height * y / 664];
  const cellXY = c => P(66 + (c % 6) * 78 + 39, 16 + Math.floor(c / 6) * 78 + 39);
  const dbl = async c => { await p.mouse.click(...cellXY(c)); await p.waitForTimeout(90); await p.mouse.click(...cellXY(c)); await p.waitForTimeout(450); };
  const word = i => p.evaluate(i => [...document.querySelectorAll('.clue')][i].querySelectorAll('.l.on').length, i);
  const letterAt = c => p.evaluate(([x, y]) => { const e = document.elementFromPoint(x, y)?.closest('[data-key]'); return e ? e.querySelector('text').textContent : '-'; }, cellXY(c));
  async function drag(from, to, shot) {
    await p.mouse.move(...cellXY(from)); await p.mouse.down();
    await p.mouse.move(...cellXY(to), { steps: 12 });
    if (shot) await p.screenshot({ path: require('os').tmpdir() + '/' + shot });
    await p.mouse.up(); await p.waitForTimeout(500);
  }
  await dbl(7); await drag(7, 8); await drag(8, 9); await drag(9, 10);
  console.log("GIOC?", await letterAt(7), await letterAt(8), await letterAt(9), await letterAt(10), "GIOCO", await word(1));
  await drag(10, 16, "gioco-held.png");
  console.log("down from C:", await letterAt(16), "GIOCO", await word(1));
  await p.screenshot({ path: require('os').tmpdir() + '/gioco.png' });
  console.log('errors', errs);
  await b.close();
})();
