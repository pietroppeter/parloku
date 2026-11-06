// Pietro (2026-11-06): ↶ undo and ↷ redo, two round buttons that come down with the menu at the top right.
// Build index.html first, then: node tests/gestures/undo.js
const { chromium, devices } = require('playwright');
const os = require('os');
(async () => {
  const b = await chromium.launch();
  const p = await (await b.newContext({ ...devices['iPhone 13'], locale: 'it-IT' })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto((process.argv[2] || 'file://' + require('path').resolve(__dirname, '../../index.html')) + '?nosplash&p=AILPST_51S.23L.04P_00ITALIA.20PASTA.40ALPI');
  await p.waitForTimeout(800);
  const cellXY = async c => { const bb = await (await p.$('#board svg')).boundingBox();
    return [bb.x + bb.width * (66 + (c % 6) * 78 + 39 - 50) / 500, bb.y + bb.height * (16 + Math.floor(c / 6) * 78 + 39) / 664]; };
  const dbl = async c => { const xy = await cellXY(c); await p.mouse.click(...xy); await p.waitForTimeout(90); await p.mouse.click(...xy); await p.waitForTimeout(450); };
  const filled = () => p.evaluate(() => [...document.querySelectorAll('#board .fg .item')].filter(e => +(e.style.transform.match(/, ([\d.]+)px/) || [0, 999])[1] < 500).length);
  const menu = async () => { if (!(await p.$eval('body', x => x.classList.contains('chrome')))) { await p.mouse.click(6, 30); await p.waitForTimeout(400); } };
  const state = () => p.evaluate(() => ['undo', 'redo'].map(id => { const e = document.getElementById(id);
    return id + (e.offsetParent === null ? ' hidden' : e.disabled ? ' off' : ' on'); }).join(', '));
  console.log('menu up, board empty:', await state());
  await menu();
  console.log('menu down, board empty:', await state());
  const r = await p.$eval('#undo', e => { const b = e.getBoundingClientRect(); return [Math.round(b.left), Math.round(b.top), Math.round(innerWidth)]; });
  console.log('undo at x, y (screen width):', r.join(', '));
  await p.mouse.click(195, 800); await p.waitForTimeout(500);
  await dbl(0); await dbl(12); await dbl(24);
  const n0 = await filled();
  await menu();
  console.log('three letters:', n0, '|', await state());
  await p.screenshot({ path: os.tmpdir() + '/undo.png' });
  await p.click('#undo'); await p.waitForTimeout(300);
  await p.click('#undo'); await p.waitForTimeout(300);
  console.log('after two undos:', await filled(), 'tiles |', await state(), '| menu still down:', await p.$eval('body', x => x.classList.contains('chrome')));
  await p.click('#redo'); await p.waitForTimeout(300);
  console.log('after a redo:', await filled(), 'tiles |', await state());
  await p.mouse.click(195, 800); await p.waitForTimeout(500);
  await dbl(12);
  await menu();
  console.log('a new move (taking back the P) forgets the redo:', await filled(), 'tiles |', await state());
  await p.waitForTimeout(4600);
  console.log('4.6 s later the menu and the buttons are gone:', await state());
  // two quick taps on ↶ with a finger: two moves back, never a zoom (iPhone Safari zooms on a double tap
  // unless the page says touch-action: manipulation)
  await menu(); const before = await filled();
  const u = await p.$eval('#undo', e => { const b = e.getBoundingClientRect(); return [b.left + b.width / 2, b.top + b.height / 2]; });
  await p.touchscreen.tap(...u); await p.waitForTimeout(150); const mid = await filled();
  await p.touchscreen.tap(...u); await p.waitForTimeout(400);
  // the last move took the P back, so the first undo brings it back (5) and the second takes the third letter away (4)
  console.log('two quick finger taps on undo:', before, '->', mid, '->', await filled(), 'tiles |', await state(), '| touch-action on the page and on undo:',
    await p.evaluate(() => [getComputedStyle(document.documentElement).touchAction, getComputedStyle(document.getElementById('undo')).touchAction].join(', ')));
  console.log('errors', errs);
  await b.close();
})();
