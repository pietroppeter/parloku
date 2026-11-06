// Pietro's snake cases (2026-11-05), in headless Chromium on an iPhone 13. Build index.html first, then: node tests/gestures/snake.js
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
  // case 4: MAGIA down column 6 in one drag
  await dbl(5);
  await walk([5, 11, 17, 23, 29]);
  console.log('case 4, one drag M→down:', await col([5, 11, 17, 23, 29]), 'MAGIA', await word(2));
  // case 1: head A on r5c6 is wrong; drag it (diagonally) to r4c5
  await walk([29, 22]);
  console.log('case 1, head moved diagonally:', await col([5, 11, 17, 23, 29]), 'r4c5', await at(22), 'MAGIA', await word(2));
  // case 3: AMICA goes down; walk the head back up
  await dbl(0);
  await walk([0, 6, 12, 18, 24], 'snake-held.png');
  console.log('AMICA down col 1:', await col([0, 6, 12, 18, 24]), 'AMICA', await word(0));
  await walk([24, 18, 12]);
  console.log('case 3, walked back up two cells:', await col([0, 6, 12, 18, 24]), 'AMICA', await word(0));
  await walk([12, 13]);
  console.log('and on to the right:', await col([0, 6, 12, 13]), 'AMICA', await word(0));
  // a non-head letter: quick drag still copies
  await walk([6, 8]);
  console.log('copy of a middle letter M → r2c3:', await at(8));
  await p.screenshot({ path: require('os').tmpdir() + '/snake.png' });
  console.log('errors', errs);
  await b.close();
})();
