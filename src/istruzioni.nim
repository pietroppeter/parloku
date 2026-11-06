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
.howto .k{display:inline-block;min-width:1.5em;padding:0 .25em;text-align:center;border-radius:.35em;border:2px solid var(--ink);
  font-weight:800;line-height:1.35;margin:0 .1em}
.howto .k.g0{background:var(--g0)} .howto .k.g1{background:var(--g1)} .howto .k.g2{background:var(--g2)}
.howto .k.given{border-width:3.5px}
.howto .w0{color:var(--w0);font-weight:800} .howto .w1{color:var(--w1);font-weight:800} .howto .w2{color:var(--w2);font-weight:800}
.howto .note{color:var(--muted);font-size:15px;margin-top:14px}
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
<li><b>3 · Lettere fisse</b>Alcune lettere sono già in griglia e hanno il bordo più spesso, come <span class="k g1 given">S</span>.
Quelle non si toccano.</li>
</ol>
<p class="note">C'è una sola soluzione, e ci si arriva ragionando: non serve tirare a indovinare.
Quando la griglia è giusta e le tre parole ci sono tutte, hai vinto.</p>

<h2>I gesti</h2>
<ul>
<li><b>Mettere una lettera</b>Trascina una delle sei lettere in basso su una casella vuota. Le lettere già in griglia non vengono mai coperte.</li>
<li><b>Copiare una lettera</b>Trascina una lettera della griglia: ne parte una copia, che puoi mettere su un'altra casella.</li>
<li><b>Spostare una lettera</b>Tienila premuta finché si solleva, poi portala dove vuoi.</li>
<li><b>Scrivere una parola</b>Trascina l'ultima lettera di una parola sulle caselle vicine: a ogni passo si aggiunge la lettera
che viene dopo, e tornando indietro la togli. Il contorno colorato cresce con la parola.</li>
<li><b>Togliere</b>Doppio tocco su una lettera: torna in basso. Se fa parte di una parola, torna in basso tutta la parola.</li>
<li><b>Riempire una casella sicura</b>Doppio tocco su una casella vuota dove può andare una sola lettera: il cerchietto di una
parola, o l'ultima casella libera di una riga, di una colonna o di un riquadro.</li>
<li><b>Dov'è una parola?</b>Tocca una parola in alto: sulla griglia il suo cerchietto o il suo contorno vibra.</li>
<li><b>Il menu</b>Tocca uno spazio vuoto: in alto compaiono <i>istruzioni</i>, <i>ancora!</i> per scegliere un altro puzzle
(quelli già risolti hanno ✓) e <i>rifaccio</i> per ricominciare. Subito dopo, per qualche secondo, puoi ancora
<i>annullare</i> il rifaccio.</li>
</ul>
<p><a class="back" href="index.html">← al gioco</a></p>
</div>
<script>
try { document.body.dataset.skin = localStorage.getItem('parloku:look') || 'niki' } catch (e) { document.body.dataset.skin = 'niki' }
</script>
"""

nbSave
