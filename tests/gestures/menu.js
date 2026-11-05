// Pietro (2026-11-05): the menu has only "istruzioni", "ancora!" (puzzle list, solved ones ticked) and "rifaccio",
// which can be undone for a few seconds, until the next move. Build index.html first, then: node tests/gestures/menu.js
const { chromium, devices } = require('playwright');
const os = require('os');
(async () => {
  const b = await chromium.launch();
  const p = await (await b.newContext({ ...devices['iPhone 13'], locale: 'it-IT' })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto((process.argv[2] || 'file://' + require('path').resolve(__dirname, '../../index.html')) + '?nosplash&p=AILPST_51S.23L.04P_00ITALIA.20PASTA.40ALPI');
  await p.waitForTimeout(800);
  const bb = await (await p.$('#board svg')).boundingBox();
  const P = (x, y) => [bb.x + bb.width * (x - 50) / 500, bb.y + bb.height * y / 664];
  const cellXY = c => P(66 + (c % 6) * 78 + 39, 16 + Math.floor(c / 6) * 78 + 39);
  const dbl = async c => { await p.mouse.click(...cellXY(c)); await p.waitForTimeout(90); await p.mouse.click(...cellXY(c)); await p.waitForTimeout(450); };
  const filled = () => p.evaluate(() => [...document.querySelectorAll('#board .fg .item')].filter(e => +(e.style.transform.match(/, ([\d.]+)px/) || [0, 999])[1] < 500).length);
  const menu = async () => { await p.mouse.click(195, 5 + (await p.evaluate(() => innerHeight)) - 10); await p.waitForTimeout(250); };
  const visible = () => p.$$eval('.picker > *', xs => xs.filter(x => x.offsetParent !== null).map(x => x.textContent.trim()));
  const reset = () => p.$eval('#reset', x => x.textContent);
  await dbl(0); await dbl(12); await dbl(24);
  const n0 = await filled();
  await p.mouse.click(195, 655); await p.waitForTimeout(300);
  console.log('menu buttons:', await visible());
  await p.screenshot({ path: os.tmpdir() + '/menu.png' });
  await p.click('#reset'); await p.waitForTimeout(300);
  console.log('after restart:', await filled(), 'tiles (was', n0 + '), button:', await reset());
  await p.click('#reset'); await p.waitForTimeout(300);
  console.log('after undo:', await filled(), 'tiles, button:', await reset());
  await p.click('#reset'); await p.waitForTimeout(300);
  await dbl(0);
  console.log('restart then a move: button', await reset(), '| tiles', await filled());
  await p.click('#reset'); await p.waitForTimeout(300);
  await p.waitForTimeout(8500);
  console.log('restart then 8.5s: button', await reset());
  await p.mouse.click(195, 655); await p.waitForTimeout(300);
  if (!(await p.$eval('body', b => b.classList.contains('chrome')))) { await p.mouse.click(195, 655); await p.waitForTimeout(300); }
  await p.click('#again'); await p.waitForTimeout(300);
  console.log('list:', await p.$$eval('#picker .btn', xs => xs.map(x => x.textContent)));
  await p.screenshot({ path: os.tmpdir() + '/again.png' });
  // solve puzzle 1 through the page's own solution, then the list ticks it
  await p.evaluate(() => localStorage.setItem('parloku:solved', 'AILPST_51S.23L.04P_00ITALIA.20PASTA.40ALPI'));
  await p.reload(); await p.waitForTimeout(800);
  await p.mouse.click(195, 655); await p.waitForTimeout(300);
  await p.click('#again'); await p.waitForTimeout(300);
  console.log('list with puzzle 1 solved:', await p.$$eval('#picker .btn', xs => xs.map(x => x.textContent)));
  await p.screenshot({ path: os.tmpdir() + '/again-solved.png' });
  await p.click('#howto'); await p.waitForTimeout(500);
  console.log('istruzioni:', await p.title());
  console.log('errors', errs);
  await b.close();
})();
