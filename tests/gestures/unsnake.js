// Pietro (2026-11-06): a double tap on a letter of a word cuts the word there: that letter and the ones after it go back below, in headless Chromium on an iPhone 13. Build index.html first, then: node tests/gestures/unsnake.js
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
  const at = c => p.evaluate(([x, y]) => { const e = document.elementFromPoint(x, y)?.closest('[data-key]'); return e ? e.querySelector('text').textContent : '-'; }, cellXY(c));
  const col = async cs => (await Promise.all(cs.map(at))).join('');
  async function walk(cells, shot) {   // one drag through the centres of `cells`
    await p.mouse.move(...cellXY(cells[0])); await p.mouse.down();
    for (const c of cells.slice(1)) { await p.mouse.move(...cellXY(c), { steps: 8 }); await p.waitForTimeout(60); }
    if (shot) await p.screenshot({ path: require('os').tmpdir() + '/' + shot });
    await p.mouse.up(); await p.waitForTimeout(500);
  }
  await dbl(5);
  await walk([5, 11, 17, 23, 29]);
  console.log('MAGIA down col 6:', await col([5, 11, 17, 23, 29]), 'MAGIA', await word(2));
  await walk([11, 13]);
  console.log('a loose copy of A on r3c2:', await at(13));
  await dbl(13);
  console.log('double tap on the loose A: r3c2', await at(13), '| MAGIA still', await col([5, 11, 17, 23, 29]), await word(2));
  await dbl(17);
  console.log('double tap on the G inside MAGIA: col 6', await col([5, 11, 17, 23, 29]), '(MA---)', 'MAGIA', await word(2));
  await dbl(11);
  console.log('double tap on the A after M: col 6', await col([5, 11, 17, 23, 29]), '(M----)');
  console.log('errors', errs);
  await b.close();
})();
