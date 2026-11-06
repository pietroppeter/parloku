// Pietro (2026-11-06): the emoji share. Every letter of a word is a ball in the word's colour, ⚫ a letter sent back,
// ⚪ any other move, six to a line; 🥳 and the dance in the first line. Build index.html first, then: node tests/gestures/share.js
const { chromium, devices } = require('playwright');
(async () => {
  const b = await chromium.launch();
  const page = async (q) => {
    const p = await (await b.newContext({ ...devices['iPhone 13'], locale: 'it-IT' })).newPage();
    p.errs = []; p.on('pageerror', e => p.errs.push(e.message));
    await p.goto((process.argv[2] || 'file://' + require('path').resolve(__dirname, '../../index.html')) + q);
    await p.waitForTimeout(800);
    await p.evaluate(() => { navigator.share = t => { window.shared = t.text; return Promise.resolve() } });
    return p;
  };
  const hint = p => p.evaluate(() => document.getElementById('hint').click());
  const share = async p => { await p.waitForTimeout(3800); await p.tap('.sharegame'); await p.waitForTimeout(200); return p.evaluate(() => window.shared); };
  // a clean game: 33 hints, one letter each
  let p = await page('?nosplash&p=1&party=snakes');
  for (let i = 0; i < 33; i++) { await hint(p); await p.waitForTimeout(40); }
  console.log('clean game, short link ?p=1:\n' + await share(p));
  console.log('errors', p.errs);
  // a slip: a letter taken back with undo, then put again with redo
  p = await page('?nosplash&p=1&party=wave');
  for (let i = 0; i < 5; i++) { await hint(p); await p.waitForTimeout(40); }
  await p.evaluate(() => { document.getElementById('undo').click(); document.getElementById('redo').click(); });
  for (let i = 0; i < 28; i++) { await hint(p); await p.waitForTimeout(40); }
  console.log('undo and redo once:\n' + await share(p));
  await p.reload(); await p.waitForTimeout(800);
  await p.evaluate(() => { navigator.share = t => { window.shared = t.text; return Promise.resolve() } });
  console.log('after a reload, same text:', (await share(p)).split('\n')[0]);
  console.log('errors', p.errs);
  // a long game: ten letters taken back and put again, 53 moves: seven lines, then … and the rest
  p = await page('?nosplash&p=1&party=letters');
  for (let i = 0; i < 5; i++) { await hint(p); await p.waitForTimeout(40); }
  for (let i = 0; i < 10; i++) await p.evaluate(() => { document.getElementById('undo').click(); document.getElementById('redo').click(); });
  for (let i = 0; i < 28; i++) { await hint(p); await p.waitForTimeout(40); }
  console.log('a long game:\n' + await share(p));
  console.log('errors', p.errs);
  await b.close();
})();
