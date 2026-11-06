// Pietro (2026-11-06): a new player is told where the menu is by a little snake spelling MENU, until the menu is opened once.
// Build index.html first, then: node tests/gestures/menuhint.js [page url] [folder for screenshots]
const { chromium, devices } = require('playwright');
const os = require('os');
(async () => {
  const b = await chromium.launch();
  const ctx = await b.newContext({ ...devices['iPhone 13'], locale: 'it-IT' });
  const p = await ctx.newPage();
  const out = process.argv[3] || os.tmpdir();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  const url = (process.argv[2] || 'file://' + require('path').resolve(__dirname, '../../index.html')) + '?nosplash&p=1';
  await p.goto(url);
  const snake = () => p.evaluate(() => { const s = document.querySelector('.hint-snake');
    return s ? s.className + ' | ' + s.querySelector('.hs-say').textContent : 'none'; });
  await p.waitForTimeout(1000);
  console.log('1 s in:', await snake());
  await p.waitForTimeout(6800);
  console.log('7.8 s in:', await snake());
  await p.screenshot({ path: out + '/menuhint-talk.png' });
  await p.mouse.click(6, 30); await p.waitForTimeout(700);
  console.log('menu down:', await p.$eval('body', x => x.classList.contains('chrome')), '| snake:', await snake(),
    '| remembered:', await p.evaluate(() => localStorage.getItem('parloku:menu')));
  await p.screenshot({ path: out + '/menuhint-eccolo.png' });
  await p.waitForTimeout(4000);
  console.log('4 s later:', await snake());
  await p.reload(); await p.waitForTimeout(8000);
  console.log('next visit, 8 s in:', await snake());
  console.log(errs.length ? 'errors: ' + errs.join('; ') : 'no errors');
  await b.close();
})();
