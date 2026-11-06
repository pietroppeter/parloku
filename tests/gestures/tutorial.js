// Pietro (2026-11-06): the 🎓 tutorial fits one phone screen. Its messages float on see-through blobs over the game,
// never on the cells, the letter or the clue the step is about. It teaches the gestures: a double tap on a sure cell,
// stretching a word from its last letter. This test plays the whole tutorial with the gesture each step teaches.
// Build index.html first, then: node tests/gestures/tutorial.js
const { chromium, devices } = require('playwright');
const os = require('os');
(async () => {
  const b = await chromium.launch();
  const p = await (await b.newContext({ ...devices['iPhone 13'], locale: 'it-IT' })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto((process.argv[2] || 'file://' + require('path').resolve(__dirname, '../../index.html')) + '?nosplash&tutorial');
  await p.waitForTimeout(900);
  const cellXY = async c => { const bb = await (await p.$('#board svg')).boundingBox();
    return [bb.x + bb.width * (66 + (c % 6) * 78 + 39 - 50) / 500, bb.y + bb.height * (16 + Math.floor(c / 6) * 78 + 39) / 664]; };
  const dbl = async c => { const xy = await cellXY(c); await p.mouse.click(...xy); await p.waitForTimeout(90); await p.mouse.click(...xy); await p.waitForTimeout(500); };
  const walk = async (a, z) => { await p.mouse.move(...await cellXY(a)); await p.mouse.down();
    await p.mouse.move(...await cellXY(z), { steps: 8 }); await p.waitForTimeout(60); await p.mouse.up(); await p.waitForTimeout(500); };
  const cellOf = rc => { const m = rc.match(/r(\d)c(\d)/); return (m[1] - 1) * 6 + (m[2] - 1); };
  const check = () => p.evaluate(() => {
    const box = e => e.getBoundingClientRect();
    const hit = (a, b) => Math.max(0, Math.min(a.right, b.right) - Math.max(a.left, b.left)) * Math.max(0, Math.min(a.bottom, b.bottom) - Math.max(a.top, b.top)) > 4;
    const coach = document.getElementById('coach');
    if (coach.hidden) return { hidden: true };
    const me = box(coach);
    const must = [...document.querySelectorAll('#board .aim, #board .glow')].map(box);
    for (const i of (coach.dataset.clues || '').split(',').filter(x => x)) must.push(box(document.querySelector(`[data-clue="${i}"]`)));
    const stacks = [...document.querySelectorAll('#board .fg .item')].map(box).filter(r => r.top > 0);
    return { text: document.getElementById('coach-text').textContent, covered: must.filter(r => hit(me, r)).length,
             lettersEnd: Math.round(Math.max(...stacks.map(r => r.bottom))) };
  });
  let bad = 0, worst = 0;
  const used = { start: 0, stretch: 0, sure: 0, show: 0 };
  for (let i = 0; i < 4; i++) { const c = await check(); bad += c.covered; worst = Math.max(worst, c.lettersEnd);
    await p.click('#coach [data-act="next"]'); await p.waitForTimeout(500); }
  for (let n = 0; n < 40; n++) {
    const c = await check(); if (c.hidden) break;
    bad += c.covered; worst = Math.max(worst, c.lettersEnd || 0);
    if (c.covered) console.log('covered:', c.text.slice(0, 60));
    if (n == 3) await p.screenshot({ path: os.tmpdir() + '/tut-stretch.png' });
    let m;
    if (/doppio tocco sulla casella/i.test(c.text)) { m = c.text.match(/quindi (r\dc\d)/); await dbl(cellOf(m[1])); used.start++; continue; }
    if ((m = c.text.match(/Allunga \S+:? .*?da (r\dc\d) a (r\dc\d)/))) { await walk(cellOf(m[1]), cellOf(m[2])); used.stretch++; continue; }
    if (/doppio tocco e/i.test(c.text)) { m = c.text.match(/(r\dc\d)/); await dbl(cellOf(m[1])); used.sure++; continue; }
    const act = await p.$('#coach [data-act="show"]') || await p.$('#coach [data-act="guide"]');
    if (!act) { console.log('end:', c.text.slice(0, 40)); break; }
    if (await act.getAttribute('data-act') == 'show') used.show++;
    await act.click(); await p.waitForTimeout(450);
  }
  console.log('gestures used:', JSON.stringify(used));
  console.log('steps covering what they talk about:', bad, '| letters end at', worst, 'of', 664);
  console.log('errors', errs);
  await b.close();
})();
