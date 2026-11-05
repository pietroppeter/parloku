// specdrag.js: plays the drag scenarios that tools/specdrag.nim collected on the built game page, in headless
// Chromium on an iPhone 13 (like tests/gestures/), and records every frame for the spec viewer.
//
//   node tools/specdrag.js scenarios.json frames.json [index.html]
//
// For each scenario: open the page on the scenario's puzzle with the start board saved as progress, do the gesture
// with real pointer events, read the board back from the page (tiles, and each word's outline from its drawing),
// and compare with the scenario. Prints one line per scenario; the JSON has the verdicts and the frames.
const { chromium, devices } = require('playwright')
const fs = require('fs'), path = require('path')

const [scenFile, outFile, page0] = process.argv.slice(2)
const pageUrl = 'file://' + path.resolve(page0 || 'index.html')
const scenarios = JSON.parse(fs.readFileSync(scenFile, 'utf8'))
const dataDir = path.resolve(path.dirname(page0 || 'index.html'), 'data')

function puzzleCode(spec) {
  // "2": data/puzzle2-*.json as a code; anything else is a code already
  if (!/^\d+$/.test(spec)) return spec
  const f = fs.readdirSync(dataDir).find(n => n.startsWith('puzzle' + spec + '-') && n.endsWith('.json'))
  if (!f) throw new Error('no data/puzzle' + spec + '-*.json')
  const p = JSON.parse(fs.readFileSync(path.join(dataDir, f), 'utf8')).problem
  return p.letters.join('') + '_' + p.letterHints.map(h => `${h.pos[0]}${h.pos[1]}${h.letter}`).join('.') +
    '_' + p.wordHints.map(h => `${h.pos[0]}${h.pos[1]}${h.word}`).join('.')
}
const decode = code => {
  const [letters, givens, words] = code.split('_')
  const items = s => (s ? s.split('.') : []).map(t => ({ r: +t[0], c: +t[1], v: t.slice(2) }))
  return { letters, givens: items(givens), words: items(words) }
}
const cellName = c => `r${Math.floor(c / 6) + 1}c${c % 6 + 1}`
const cellOf = s => /^r[1-6]c[1-6]$/.test(s) ? (+s[1] - 1) * 6 + (+s[3] - 1) : -1
const cellPos = c => [66 + (c % 6) * 78 + 39, 16 + Math.floor(c / 6) * 78 + 39]
const stackPos = li => [150 + (li % 3) * 150, 546 + Math.floor(li / 3) * 74]
const show = g => [0, 1, 2, 3, 4, 5].map(r => '      ' + g.slice(r * 6, r * 6 + 6).split('').join(' ')).join('\n')

;(async () => {
  const browser = await chromium.launch()
  const strings = [], strIx = new Map()
  const str = s => { if (!strIx.has(s)) { strIx.set(s, strings.length); strings.push(s) } return strIx.get(s) }
  const out = []
  let failed = 0, todo = 0, done = 0
  for (const [n, s] of scenarios.entries()) {
    const code = puzzleCode(s.puzzle)
    const puz = decode(code)
    const problems = []
    // the start board as saved progress: tile id li*6+k for the k-th copy of letter li
    const cells = [], used = [0, 0, 0, 0, 0, 0]
    for (let c = 0; c < 36; c++) {
      const ch = s.start[c] || '.', li = puz.letters.indexOf(ch)
      cells.push(li >= 0 ? li * 6 + used[li]++ : -1)
    }
    for (const g of puz.givens) if (s.start[g.r * 6 + g.c] !== g.v) problems.push(`start board misses the given ${g.v} at ${cellName(g.r * 6 + g.c)}`)
    const ctx = await browser.newContext({ ...devices['iPhone 13'] })
    await ctx.addInitScript(([k, v]) => { try { localStorage.setItem(k, v); localStorage.setItem('parloku:look', 'niki') } catch (e) {} },
      ['parloku:' + code, cells.join(',') + ';0;0;0'])
    const p = await ctx.newPage()
    const errs = []; p.on('pageerror', e => errs.push(e.message))
    await p.goto(pageUrl + '?nosplash&lang=en&p=' + code)
    await p.waitForTimeout(500)
    const bb = await (await p.$('#board svg')).boundingBox()
    const toScreen = ([x, y]) => [bb.x + bb.width * (x - 50) / 500, bb.y + bb.height * y / 664]
    const pointOf = w => {
      const c = cellOf(w)
      if (c >= 0) return cellPos(c)
      if (w.startsWith('stack ')) return stackPos(puz.letters.indexOf(w.slice(6).trim()))
      if (w === 'off') return [560, 650]
      throw new Error('unknown waypoint ' + w)
    }
    const tag = `s${n}m`
    const boards = [], frames = [], tiles = {}
    let lastBoard = ''
    let everLifted = false
    // one frame: every tile's place, the board drawing, the outlines, the held tile and the finger
    const grab = async (at) => {
      const st = await p.evaluate(() => {
        const svg = document.querySelector('#board svg')
        const pos = {}, look = {}
        let held = ''
        for (const n of svg.querySelectorAll('.fg [data-key]')) {
          const m = /translate\(([-\d.]+)px,\s*([-\d.]+)px\)/.exec(n.style.transform) || []
          pos[n.dataset.key] = [+(+m[1]).toFixed(1), +(+m[2]).toFixed(1)]
          look[n.dataset.key] = n.innerHTML
          if (n.classList.contains('lifted')) held = n.dataset.key
        }
        return { pos, look, held, bg: svg.querySelector('.bg').innerHTML, top: svg.querySelector('.overlay').innerHTML }
      })
      if (st.held) everLifted = true
      for (const k in st.look) if (!(k in tiles)) tiles[k] = str(st.look[k])
      const top = st.top.replace(/id="wm/g, `id="${tag}`).replace(/url\(#wm/g, `url(#${tag}`)
      const key = JSON.stringify(st.pos) + st.bg + top
      if (key !== lastBoard) { boards.push({ pos: st.pos, bg: str(st.bg), top: str(top) }); lastBoard = key }
      const held = st.held
      frames.push({ b: boards.length - 1, p: at ? at.map(v => +v.toFixed(1)) : [-100, -100], k: held })
      return st
    }
    for (let k = 0; k < 4; k++) await grab(null)
    if ((s.gesture === 'drag' || s.gesture === 'hold') && s.points.length >= 2) {
      let at = pointOf(s.points[0])
      await p.mouse.move(...toScreen(at)); await p.mouse.down()
      if (s.gesture === 'hold') { await p.waitForTimeout(450); await grab(at) }
      for (const w of s.points.slice(1)) {
        const to = pointOf(w), from = at
        for (let k = 1; k <= 10; k++) {
          at = [from[0] + (to[0] - from[0]) * k / 10, from[1] + (to[1] - from[1]) * k / 10]
          await p.mouse.move(...toScreen(at)); await p.waitForTimeout(16)
          await grab(at)
        }
        await p.waitForTimeout(60); await grab(at)
      }
      await p.mouse.up()
      for (let k = 0; k < 6; k++) { await p.waitForTimeout(60); await grab(null) }
    } else if (s.gesture === 'double-tap') {
      const at = pointOf(s.points[0])
      await p.mouse.click(...toScreen(at)); await p.waitForTimeout(90); await p.mouse.click(...toScreen(at))
      for (let k = 0; k < 8; k++) { await p.waitForTimeout(60); await grab(at) }
    } else {
      for (let k = 0; k < 6; k++) await grab(null)
    }
    await p.waitForTimeout(400)
    // the board after: each tile in the cell its centre sits in
    const end = await grab(null)
    const grid = Array(36).fill('.')
    for (const k in end.pos) {
      const [x, y] = end.pos[k], col = Math.floor((x - 66) / 78), row = Math.floor((y - 16) / 78)
      if (col >= 0 && col < 6 && row >= 0 && row < 6) grid[row * 6 + col] = puz.letters[Math.floor(+k.slice(1) / 6)]
    }
    const endGrid = grid.join('')
    if (s.refused && everLifted) problems.push(`the tile at ${s.points[0]} can be picked up`)
    if (s.finish && s.finish.length !== 36) problems.push(`the end board needs 36 cells, it has ${s.finish.length}`)
    else if (s.finish && endGrid !== s.finish) problems.push(`end board differs. Expected:\n${show(s.finish)}\n    got:\n${show(endGrid)}`)
    // outlines, read from the drawing: a path through cell centres, or a ring on the start cell
    for (const o of s.outlines) {
      const wi = puz.words.findIndex(w => w.v === o.word)
      if (wi < 0) { problems.push(`no word ${o.word} in this puzzle`); continue }
      const got = await p.evaluate(i => {
        const m = document.querySelector(`#board svg .overlay mask[id$="${i}"] path.wm`)
        if (!m) return null
        return [...m.getAttribute('d').matchAll(/([-\d.]+),([-\d.]+)/g)].map(x => [+x[1], +x[2]])
      }, wi)
      let cellsGot
      if (got) cellsGot = got.map(([x, y]) => cellName(Math.floor((y - 16) / 78) * 6 + Math.floor((x - 66) / 78)))
      else {
        const sc = puz.words[wi].r * 6 + puz.words[wi].c
        cellsGot = endGrid[sc] === o.word[0] ? [cellName(sc)] : []
      }
      if (cellsGot.join(' ') !== o.cells.join(' ')) problems.push(`outline ${o.word}: expected ${o.cells.join(' ')}, got ${cellsGot.join(' ')}`)
    }
    if (errs.length) problems.push('page errors: ' + errs.join('; '))
    await ctx.close()
    let verdict = problems.length ? (s.change ? 'todo' : 'fail') : (s.change ? 'done' : 'pass')
    if (verdict === 'fail') failed++; else if (verdict === 'todo') todo++; else if (verdict === 'done') done++
    console.log({ pass: 'ok  ', todo: 'todo', done: 'done', fail: 'FAIL' }[verdict], `${s.path}:${s.line}  ${s.scenario}`)
    if (verdict === 'fail' || verdict === 'todo') for (const q of problems) console.log('    ' + q)
    out.push({ ...s, verdict, problems, letters: puz.letters, tiles, boards, frames })
  }
  await browser.close()
  fs.writeFileSync(outFile, JSON.stringify({ strings, scenarios: out }))
  console.log(`${scenarios.length} drag scenarios. Specs: ${scenarios.length - failed - todo - done} pass, ${failed} fail. ` +
    `Open changes: ${done} done, ${todo} still to do`)
  process.exit(failed ? 1 : 0)
})()
