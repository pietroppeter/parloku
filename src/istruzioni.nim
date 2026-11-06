## Come si gioca a Parloku: prima le regole, poi i gesti. Pagina `istruzioni.html`, aperta dal menu del gioco.
import std/[json, os]
import nimib
import style

nbInit
nb.doc.filename = currentSourcePath().parentDir.parentDir / "istruzioni.html"
nb.doc.context["title"] = %"Parloku: come si gioca"
nb.doc.context["stylesheet"] = %(pageStyle & """
<style>
.howto h1{font-size:clamp(36px,9vw,56px);margin:14px 0 6px}
.howto .back{display:inline-block;margin:10px 0 4px;font-weight:700;color:var(--ink)}
.howto h2{font-size:24px;margin:26px 0 10px}
.howto ol,.howto ul{padding-left:0;list-style:none;margin:0;display:flex;flex-direction:column;gap:10px}
.howto li{background:var(--card);border:var(--border) solid var(--line);border-radius:14px;padding:10px 14px;line-height:1.45}
.howto li b{display:block;font-family:var(--font-head);font-size:18px}
.howto .k{display:inline-grid;place-items:center;width:1.7em;height:1.7em;border-radius:50%;border:1.5px solid var(--ink);
  font:var(--glyph-weight) 1em/1 var(--font-glyph);vertical-align:-.32em;margin:-.2em .1em 0;padding-bottom:.14em;box-sizing:border-box}   /* a round tile, as in the game */
.howto .k.g0{background:var(--g0)} .howto .k.g1{background:var(--g1)} .howto .k.g2{background:var(--g2)}
.howto .k.given{border-width:3.5px}
.howto .w0{color:var(--w0);font-weight:800} .howto .w1{color:var(--w1);font-weight:800} .howto .w2{color:var(--w2);font-weight:800}
.howto .note{color:var(--muted);font-size:15px;margin-top:14px}
.howto ul.cases{list-style:disc;padding-left:1.2em;margin:4px 0;display:block}
.howto ul.cases li{background:none;border:0;border-radius:0;padding:0;margin:2px 0}
.howto .do{display:block;margin-top:8px;font-weight:600}
.howto .try{margin:10px -4px 2px;display:flex;flex-direction:column;align-items:center;gap:6px}
.howto .try iframe{width:min(100%,330px);height:600px;border:var(--border) solid var(--line);border-radius:14px;background:var(--bg)}
.howto .again{font:700 14px var(--font-body);border:var(--border) solid var(--ink);background:var(--card);color:var(--ink);border-radius:999px;padding:5px 14px;cursor:pointer}
</style>""")
nb.doc.context["highlight"] = %""
nb.doc.context["disableHighlightJs"] = %true
func pageHeader(blk: JsonNode, nb: Nb): string = ""
nb.backend.partials["header"] = pageHeader

nbRawHtml: """
<div class="howto">
<a class="back" href="index.html">← al gioco</a>
<h1>Come si gioca</h1>

<h2>Le regole</h2>
<ol>
<li><b>1 · Un sudoku di lettere</b>La griglia è 6×6, divisa in sei riquadri da 2×3. Ci sono sei lettere: ognuna va
una volta sola in ogni riga, in ogni colonna e in ogni riquadro.</li>
<li><b>2 · Tre parole nascoste</b>In alto ci sono tre parole, ognuna con il suo colore:
<span class="w0">rosso</span>, <span class="w1">verde</span>, <span class="w2">blu</span>.
Una parola parte dalla casella con il cerchietto del suo colore e si legge una lettera dopo l'altra,
passando ogni volta a una casella accanto: su, giù, a destra o a sinistra, mai in diagonale.</li>
<li><b>3 · Lettere fisse</b>Le lettere che metti tu hanno il bordo sottile, come <span class="k" style="background:var(--g0);color:var(--i0)">A</span>.
Alcune lettere sono già in griglia quando il puzzle parte, e hanno il bordo più spesso, come <span class="k given" style="background:var(--g4);color:var(--i4)">S</span>:
quelle restano dove sono (se le trascini, ne parte una copia).</li>
</ol>
<p class="note">C'è una sola soluzione, e ci si arriva ragionando: non serve tirare a indovinare.
Quando la griglia è giusta e le tre parole ci sono tutte, hai vinto.</p>

<h2>I gesti</h2>
<p class="note">Sotto ogni gesto c'è una piccola griglia vera: provalo lì. Il primo puzzle è sempre ITALIA · PASTA · ALPI, e qui
non si salva niente. <i>↺ da capo</i> la rimette com'era.</p>
<ul>
<li><b>Mettere una lettera</b>Trascina una delle sei lettere in basso su una casella vuota. Le lettere già in griglia non vengono mai coperte.
<span class="do">Prova: porta la I sulla casella con il quadratino rosso, in alto a sinistra.</span><div class="try"><iframe loading="lazy" src="index.html?nosplash&amp;demo&amp;p=AILPST_51S.23L.04P_00ITALIA.20PASTA.40ALPI" title="Mettere una lettera"></iframe><button class="again" type="button">↺ da capo</button></div></li>
<li><b>Copiare una lettera</b>Trascina una lettera della griglia: ne parte una copia, che puoi mettere su un'altra casella.
<span class="do">Prova: trascina la P già in griglia, in alto a destra, e lasciala più in basso.</span><div class="try"><iframe loading="lazy" src="index.html?nosplash&amp;demo&amp;p=AILPST_51S.23L.04P_00ITALIA.20PASTA.40ALPI" title="Copiare una lettera"></iframe><button class="again" type="button">↺ da capo</button></div></li>
<li><b>Spostare una lettera</b>Tienila premuta finché si solleva, poi portala dove vuoi.
<span class="do">Prova: la T in alto è nel posto sbagliato. Tienila premuta e spostala una casella a sinistra.</span><div class="try"><iframe loading="lazy" src="index.html?nosplash&amp;demo&amp;p=AILPST_51S.23L.04P_00ITALIA.20PASTA.40ALPI&amp;g=2T" title="Spostare una lettera"></iframe><button class="again" type="button">↺ da capo</button></div></li>
<li><b>Scrivere una parola</b>Trascina l'ultima lettera di una parola sulle caselle vicine: a ogni passo si aggiunge la lettera
che viene dopo, e tornando indietro la togli. Il contorno colorato cresce con la parola.
<span class="do">Prova: trascina la I di ITALIA verso destra: arrivano la T e la A. Poi torna indietro.</span><div class="try"><iframe loading="lazy" src="index.html?nosplash&amp;demo&amp;p=AILPST_51S.23L.04P_00ITALIA.20PASTA.40ALPI&amp;g=0I" title="Scrivere una parola"></iframe><button class="again" type="button">↺ da capo</button></div></li>
<li><b>Togliere</b>Doppio tocco su una lettera: torna in basso. Se fa parte di una parola, la parola si accorcia lì: tornano in basso
quella lettera e quelle dopo, le prime restano.
<span class="do">Prova: doppio tocco sulla T da sola, al centro. Poi doppio tocco sulla T di ITALIA: resta solo la I.</span><div class="try"><iframe loading="lazy" src="index.html?nosplash&amp;demo&amp;p=AILPST_51S.23L.04P_00ITALIA.20PASTA.40ALPI&amp;g=0I,1T,2A,20T" title="Togliere"></iframe><button class="again" type="button">↺ da capo</button></div></li>
<li><b>Riempire una casella sicura</b>Con un doppio tocco su una casella vuota, la lettera si mette da sola, ma solo in due casi:
<ul class="cases"><li>è la casella con il quadratino, dove parte una parola: arriva la sua prima lettera;</li>
<li>è l'ultima casella libera di una riga, di una colonna o di un riquadro: arriva la lettera che manca.</li></ul>
Sulle altre caselle il doppio tocco non fa niente: lì la lettera la trovi tu.
<span class="do">Prova: doppio tocco sull'ultima casella della prima riga, sull'ultima libera della terza colonna, sull'ultima libera del riquadro in basso a destra, e poi sul quadratino verde.</span><div class="try"><iframe loading="lazy" src="index.html?nosplash&amp;demo&amp;p=AILPST_51S.23L.04P_00ITALIA.20PASTA.40ALPI&amp;g=0I,1T,2A,3S,8L,14S,20T,26P,27T,28I,33P,34L,35A" title="Riempire una casella sicura"></iframe><button class="again" type="button">↺ da capo</button></div></li>
<li><b>Dov'è una parola?</b>Tocca una parola in alto: sulla griglia il suo quadratino o il suo contorno vibra.
<span class="do">Prova: tocca ALPI.</span><div class="try"><iframe loading="lazy" src="index.html?nosplash&amp;demo&amp;p=AILPST_51S.23L.04P_00ITALIA.20PASTA.40ALPI" title="Dov'è una parola?"></iframe><button class="again" type="button">↺ da capo</button></div></li>
<li><b>Due lettere che si scontrano</b>Se la stessa lettera è due volte nella stessa riga, colonna o riquadro, le due lettere
tremano come biglie inquiete: dondolano a destra e a sinistra, prima piano e poi, per qualche secondo, un po' di più. Niente diventa
rosso e niente ti blocca. Mentre tieni una lettera col dito, non tremano. Basta spostarne o toglierne una e si fermano.
Il gioco ti dice solo quando due lettere si scontrano, non se una lettera è giusta: quello lo scopri ragionando.
<span class="do">Prova: le due A in alto si scontrano. Fai doppio tocco su una delle due.</span><div class="try"><iframe loading="lazy" src="index.html?nosplash&amp;demo&amp;p=AILPST_51S.23L.04P_00ITALIA.20PASTA.40ALPI&amp;g=2A,5A" title="Due lettere che si scontrano"></iframe><button class="again" type="button">↺ da capo</button></div></li>
<li><b>Il menu</b>Nel gioco, tocca uno spazio vuoto sopra la griglia: in alto compaiono <i>istruzioni</i>, <i>ancora!</i> per scegliere un altro puzzle
(quelli già risolti hanno ✓) e <i>rifaccio</i> per ricominciare. Subito dopo, per qualche secondo, puoi ancora
<i>annullare</i> il rifaccio.</li>
</ul>
<p><a class="back" href="index.html">← al gioco</a></p>
</div>
"""

nbJsFromCode:
  import std/dom
  proc setSkin(e: Element, v: cstring) {.importjs: "#.dataset.skin = #".}
  proc frameOf(e: Element): Element {.importjs: "#.closest('.try').querySelector('iframe')".}
  proc reload(f: Element) {.importjs: "(f => { f.src = f.src })(#)".}
  proc onHeight(cb: proc (f: Element, h: float)) {.importjs:
    "(cb => addEventListener('message', ev => { const h = ev.data && ev.data.parlokuHeight; if (!h) return; " &
    "for (const f of document.querySelectorAll('.try iframe')) if (f.contentWindow === ev.source) cb(f, h) }))(#)".}
  proc setHeight(f: Element, h: float) {.importjs: "#.style.height = # + 'px'".}
  document.body.setSkin("niki")          # the game's one look
  # each board as tall as its game (words, grid and the six letters): the game in the frame says how tall it is
  onHeight(proc (f: Element, h: float) = f.setHeight(h))
  # ↺ da capo: the practice board starts again from its letters
  for b in document.querySelectorAll(".try .again"):
    b.addEventListener("click", proc (ev: Event) =
      let f = Element(ev.currentTarget).frameOf
      f.reload)

nbSave
