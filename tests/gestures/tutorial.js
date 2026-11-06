// Pietro (2026-11-06): the 🎓 tutorial fits one phone screen. Its messages float on see-through blobs over the game,
// never on the cells, the letter or the clue the step is about. Build index.html first, then: node tests/gestures/tutorial.js
const { chromium, devices } = require('playwright');
const os = require('os');
(async () => {
  const b = await chromium.launch();
  const p = await (await b.newContext({ ...devices['iPhone 13'], locale: 'it-IT' })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto((process.argv[2] || 'file://' + require('path').resolve(__dirname, '../../index.html')) + '?nosplash&tutorial');
  await p.waitForTimeout(900);
  const check = () => p.evaluate(() => {
    const box = e => e.getBoundingClientRect();
    const hit = (a, b) => Math.max(0, Math.min(a.right, b.right) - Math.max(a.left, b.left)) * Math.max(0, Math.min(a.bottom, b.bottom) - Math.max(a.top, b.top)) > 4;
    const coach = document.getElementById('coach');
    if (coach.hidden) return { hidden: true };
    const me = box(coach);
    const must = [...document.querySelectorAll('#board .aim, #board .glow')].map(box);
    for (const i of (coach.dataset.clues || '').split(',').filter(x => x)) must.push(box(document.querySelector(`[data-clue="${i}"]`)));
    const stacks = [...document.querySelectorAll('#board .fg .item')].map(box).filter(r => r.top > 0);
    return { text: document.getElementById('coach-text').textContent.slice(0, 40), covered: must.filter(r => hit(me, r)).length, of: must.length,
             blob: [Math.round(me.top), Math.round(me.bottom)], lettersEnd: Math.round(Math.max(...stacks.map(r => r.bottom))), screen: innerHeight };
  });
  let bad = 0, worst = 0;
  for (let i = 0; i < 4; i++) { const c = await check(); console.log('intro', i, JSON.stringify(c)); bad += c.covered; worst = Math.max(worst, c.lettersEnd);
    if (i == 0) await p.screenshot({ path: os.tmpdir() + '/tut0.png' });
    await p.click('#coach [data-act="next"]'); await p.waitForTimeout(500); }
  for (let n = 0; n < 40; n++) {
    const c = await check(); if (c.hidden) break;
    if (n < 6 || c.covered) console.log('step', n, JSON.stringify(c));
    bad += c.covered; worst = Math.max(worst, c.lettersEnd || 0);
    if (n == 1) await p.screenshot({ path: os.tmpdir() + '/tut1.png' });
    const act = await p.$('#coach [data-act="show"]') || await p.$('#coach [data-act="guide"]');
    if (!act) { console.log('end:', c.text); break; }
    await act.click(); await p.waitForTimeout(450);
  }
  console.log('steps covering what they talk about:', bad, '| letters end at', worst, 'of', 664);
  console.log('errors', errs);
  await b.close();
})();
