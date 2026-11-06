// Pietro (2026-11-06): notes. A swipe down in an empty spot below the board makes the letters small ("letterine"),
// a swipe up makes them big ("letterone"); with small letters a drag writes a note. The drag scenarios in the
// take-notes-with-small-letters change cover the rules; this checks what they can't: what is saved, restart, the
// grab area of a small letter, and swipes that must not switch. Build index.html first, then: node tests/gestures/notes.js
const { chromium, devices } = require('playwright');
const os = require('os');
const code = 'ACGIMO_41I.42O.54I.55O_00AMICA.11GIOCO.05MAGIA';
(async () => {
  const b = await chromium.launch();
  const ctx = await b.newContext({ ...devices['iPhone 13'], locale: 'it-IT' });
  const p = await ctx.newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  const url = (process.argv[2] || 'file://' + require('path').resolve(__dirname, '../../index.html')) + '?nosplash&p=' + code;
  await p.goto(url); await p.waitForTimeout(800);
  const at = async (x, y) => { const bb = await (await p.$('#board svg')).boundingBox(); return [bb.x + bb.width * (x - 50) / 500, bb.y + bb.height * y / 664]; };
  const cell = c => [66 + (c % 6) * 78 + 39, 16 + Math.floor(c / 6) * 78 + 39];
  const drag = async (from, to) => {
    await p.mouse.move(...await at(...from)); await p.mouse.down();
    for (let k = 1; k <= 10; k++) { await p.mouse.move(...await at(from[0] + (to[0] - from[0]) * k / 10, from[1] + (to[1] - from[1]) * k / 10)); await p.waitForTimeout(16); }
    await p.mouse.up(); await p.waitForTimeout(400);
  };
  const small = () => p.$eval('#board svg', s => s.classList.contains('small'));
  const notes = () => p.$$eval('#board .fg [data-key^="m"]', xs => xs.map(x => x.dataset.key).sort().join(' '));
  const placed = () => p.$$eval('#board .fg .item:not(.home):not(.mark)', xs => xs.length);
  let bad = 0;
  const check = (what, got, want) => { const ok = JSON.stringify(got) === JSON.stringify(want); if (!ok) bad++; console.log(ok ? 'ok  ' : 'FAIL', what, ok ? '' : `(got ${JSON.stringify(got)}, want ${JSON.stringify(want)})`); };

  await drag([150, 546], [150, 640]);                 // a drag that starts on a letter is not a swipe
  check('a drag from a letter does not switch', await small(), false);
  await drag([225, 520], [345, 540]);                 // sideways
  check('a sideways swipe does not switch', await small(), false);
  await drag([225, 520], [225, 640]);
  check('swipe down: small letters', await small(), true);
  await p.screenshot({ path: os.tmpdir() + '/notes-small.png' });
  await drag([150 - 26, 546 - 26], cell(14));         // grabbed near the corner of the outline, far from the small tile
  check('a small letter is grabbed anywhere in its outline', await notes(), 'm14-0');
  await drag([300, 546], cell(14)); await drag([150, 620], cell(15));
  check('more notes', await notes(), 'm14-0 m14-1 m15-3');
  check('no letter placed while small', await placed(), 4);
  await p.reload(); await p.waitForTimeout(800);
  check('reload keeps the size', await small(), true);
  check('reload keeps the notes', await notes(), 'm14-0 m14-1 m15-3');
  await drag([225, 640], [225, 520]);
  check('swipe up: big letters', await small(), false);
  await drag([150, 546], cell(15));                   // a big A over the notes of r3c4
  check('a letter hides its cell\'s notes', await notes(), 'm14-0 m14-1');
  await p.screenshot({ path: os.tmpdir() + '/notes-big.png' });
  await drag([225, 520], [225, 640]);
  await p.mouse.click(6, 30); await p.waitForTimeout(300);
  await p.click('#reset'); await p.waitForTimeout(400);
  check('restart clears the notes', await notes(), '');
  check('restart keeps the size', await small(), true);
  await p.click('#reset'); await p.waitForTimeout(400);
  check('undo restart brings them back', await notes(), 'm14-0 m14-1');
  if (errs.length) { bad++; console.log('page errors:', errs); }
  await b.close();
  process.exit(bad ? 1 : 0);
})();
