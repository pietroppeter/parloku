// Pietro (2026-11-05): the menu slides down from a tap above the grid and back up on a tap in the game; "ancora!" lists the puzzles; a new puzzle comes in from the right, piece by piece. Run: node tests/gestures/switch.js
const { chromium, devices } = require('playwright');
(async () => {
  const b = await chromium.launch();
  const p = await (await b.newContext({ ...devices['iPhone 13'], locale: 'it-IT' })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto((process.argv[2] || 'file://' + require('path').resolve(__dirname, '../../index.html')) + '?nosplash');
  await p.waitForTimeout(800);
  const vis = () => p.$$eval('.picker > *, #picker > *', xs => xs.filter(x => x.offsetParent !== null && getComputedStyle(x).display !== 'none').map(x => x.textContent.trim()));
  const mode = () => p.evaluate(() => document.body.className);
  console.log('clues top', await p.$eval('#clues', e => e.getBoundingClientRect().top));
  await p.mouse.click(195, 400); await p.waitForTimeout(400);
  console.log('tap in game, focus:', await mode());
  await p.mouse.click(195, 30); await p.waitForTimeout(500);
  console.log('tap on top:', await mode(), await vis());
  await p.screenshot({ path: require('os').tmpdir() + '/m-open.png' });
  await p.mouse.click(195, 500); await p.waitForTimeout(500);
  console.log('tap in game:', await mode());
  await p.mouse.click(195, 30); await p.waitForTimeout(400);
  await p.click('#again'); await p.waitForTimeout(300);
  console.log('listing:', await vis());
  await p.screenshot({ path: require('os').tmpdir() + '/m-list.png' });
  await p.click('#picker .btn.on'); await p.waitForTimeout(400);
  console.log('tap current: ', await mode());
  await p.mouse.click(195, 30); await p.waitForTimeout(400);
  await p.click('#again'); await p.waitForTimeout(300);
  await p.click('#picker .btn:not(.on)'); 
  for (const t of [150, 450, 900, 1300, 1900]) { await p.waitForTimeout(t - (t > 150 ? [150,450,900,1300,1900][[150,450,900,1300,1900].indexOf(t)-1] : 0)); await p.screenshot({ path: __dirname + `/sw${t}.png` }); }
  console.log('clues now', await p.$$eval('.clue', xs => xs.map(x => x.textContent.slice(0, 8))));
  await p.waitForTimeout(500);
  console.log('anims left', await p.evaluate(() => document.getAnimations().length), errs);
  await b.close();
})();
