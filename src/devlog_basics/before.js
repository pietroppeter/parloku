// Screenshot of the game as it was before the "back to basics" devlog, with the box of every UI piece.
// Usage, from the repo root:
//   git show 23ff897:index.html > /tmp/before.html && node src/devlog_basics/before.js /tmp/before.html
// Writes devlog/basics/before.png and devlog/basics/before.json (piece boxes, in % of the image).
const { chromium } = require('playwright');
const path = require('path');
const file = path.resolve(process.argv[2]);
const out = path.resolve(__dirname, '../../devlog/basics');
(async () => {
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 2 });
  await p.goto('file://' + file + '?skin=munari&lang=en');
  await p.waitForTimeout(1200);
  // a game in progress: a few hints, then one tile lifted is not possible in a still, so just hints
  for (let i = 0; i < 6; i++) { await p.click('#hint'); await p.waitForTimeout(400); }
  await p.waitForTimeout(600);
  const H = await p.evaluate(() => document.querySelector('.rules').getBoundingClientRect().bottom + scrollY + 12);
  const boxes = await p.evaluate((H) => {
    const r = e => { const q = e.getBoundingClientRect(); return [q.left, q.top + scrollY, q.width, q.height]; };
    const svg = document.querySelector('#board svg');
    const s = svg.getBoundingClientRect(), k = s.width / 600;
    const vb = (x, y, w, h) => [s.left + x * k, s.top + scrollY + y * k, w * k, h * k];
    const mk = document.querySelector('.overlay .mk').getBoundingClientRect();
    const given = [...document.querySelectorAll('.fg .item')].find(g => g.querySelector('.gv')).getBoundingClientRect();
    const pieces = {
      header: r(document.querySelector('header')),
      skins: r(document.querySelector('.skins')),
      langs: r(document.querySelector('.langs')),
      title: (() => { const a = r(document.querySelector('h1')), c = r(document.querySelector('.lede')); return [a[0], a[1], c[2], c[1] + c[3] - a[1]]; })(),
      picker: r(document.querySelector('.picker')),
      clues: r(document.querySelector('#clues')),
      marker: [mk.left - 3, mk.top + scrollY - 3, mk.width + 6, mk.height + 6],
      board: vb(51, 21, 498, 498),
      given: [given.left, given.top + scrollY, given.width, given.height],
      stacks: vb(10, 528, 580, 100),
      machinery: r(document.querySelector('.ghost-toggle')),
      meta: r(document.querySelector('#meta')),
      actions: r(document.querySelector('.status .acts')),
      rules: r(document.querySelector('.rules')),
    };
    const W = document.documentElement.clientWidth, out = {};
    for (const [n, [x, y, w, h]] of Object.entries(pieces))
      out[n] = [x / W * 100, y / H * 100, w / W * 100, h / H * 100].map(v => +v.toFixed(2));
    return out;
  }, H);
  await p.screenshot({ path: out + '/before.png', clip: { x: 0, y: 0, width: 390, height: H }, fullPage: true });
  require('fs').writeFileSync(out + '/before.json', JSON.stringify(boxes, null, 1));
  console.log('height', H, boxes);
  await b.close();
})();
