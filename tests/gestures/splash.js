// The daily splash and the first lesson (src/splashrt.nim): first visit, coming back, skipping, and "Guide me" into the tutorial.
// Build index.html first, then: node tests/gestures/splash.js
const { chromium, devices } = require('playwright');
(async () => {
  const url = process.argv[2] || 'file://' + require('path').resolve(__dirname, '../../index.html');
  const b = await chromium.launch();
  const ctx = await b.newContext({ ...devices['iPhone 13'], locale: 'en-US' });
  const p = await ctx.newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  const shown = () => p.evaluate(() => !document.getElementById('splash').hidden);
  await p.goto(url); await p.waitForTimeout(700);
  console.log('first visit:', await shown(), '|', await p.textContent('.sp-first'), '| buttons:',
    (await p.$$eval('.sp-acts .sp-btn', bs => bs.map(x => x.textContent))).join(' / '), '| lang buttons:', (await p.$$('[data-lang]')).length);
  await p.click('[data-go="play"]'); await p.waitForTimeout(500);
  console.log('after "Lo conosco":', await shown());
  await p.goto(url); await p.waitForTimeout(700);
  console.log('coming back:', await shown(), '|', await p.textContent('.sp-acts'));
  await p.waitForTimeout(3300);
  console.log('3.2 s later:', await shown());
  await p.goto(url + '?day=2026-12-25'); await p.waitForTimeout(700);
  console.log('Christmas:', await p.textContent('.sp-line'));
  await p.goto(url + '?learn'); await p.waitForTimeout(700);
  await p.click('#tu-skip'); await p.waitForTimeout(500);
  console.log('lesson skipped:', !(await shown()));
  await p.goto(url + '?learn'); await p.waitForTimeout(500);
  for (let i = 0; i < 12; i++) {
    await p.waitForSelector('#tu-acts [data-v]', { timeout: 15000 });
    const vs = await p.$$eval('#tu-acts [data-v]', bs => bs.map(x => x.dataset.v));
    if (vs.includes('guide')) { await p.click('#tu-acts [data-v="guide"]'); break; }
    await p.click('#tu-acts [data-v]');
  }
  await p.waitForTimeout(800);
  console.log('after "Guide me":', await shown() ? 'splash still open' : 'splash closed', '| coach:', (await p.textContent('#coach-text')).slice(0, 40));
  console.log('nosplash:', await (async () => { await p.goto(url + '?nosplash'); await p.waitForTimeout(500); return await shown(); })());
  console.log('errors', errs);
  await b.close();
})();
