## Come funziona il builder di Parloku: i gesti e cosa calcola. La pagina del builder è `builder.html`
## (src/builder.nim), tenuta compatta per poter giocare senza scorrere; le spiegazioni stanno qui.
import std/[json, os, strformat, strutils]
import nimib
import style, builder_style
import parloku/[types, solver]

nbInit
nb.doc.filename = currentSourcePath().parentDir.parentDir / "builder-howto.html"
nb.doc.context["title"] = %"Parloku builder: come funziona"
nb.doc.context["stylesheet"] = %(pageStyle & builderCss)
nb.doc.context["highlight"] = %""
nb.doc.context["disableHighlightJs"] = %true
func pageHeader(blk: JsonNode, nb: Nb): string = ""
nb.backend.partials["header"] = pageHeader

nbText: """
# Parloku builder: come funziona

[← torna al builder](builder.html)

**Parole.** Ogni parola in alto ha un quadratino alla fine: trascina la parola (da qualunque punto della sua riga) su una casella e la parola parte da lì con la sua prima lettera. Tieni premuta l'ultima lettera della parola: compaiono le caselle dove può andare la successiva, trascina lì (o tocca una di quelle) e la parola si allunga con la lettera giusta. Puoi anche trascinare la testa della parola (l'ultima lettera) lungo le caselle: ogni casella libera vicina in cui passi aggiunge la lettera successiva, e tornando sulla penultima la parola si accorcia. Se la lasci su una casella vuota senza aver fatto passi, la testa si sposta lì, come nel gioco.

**Lettere forzate.** Un doppio tocco su una casella vuota con una sola lettera a matita ce la mette; se è la lettera successiva di una parola che finisce accanto, la parola la prende.

**Togliere.** Un doppio tocco su una lettera la rimanda giù; se è in una parola, se ne vanno anche le lettere dopo. Un doppio tocco sulla riga della parola in alto (o sulla sua prima lettera) toglie tutta la parola.

**Gioco.** Le altre lettere si trascinano dal basso come nel gioco: un trascinamento da una lettera sulla griglia ne fa una copia, tenendo premuto la sposti.

**Ordine delle lettere.** Tieni premuta una lettera sotto: le sei lettere si mettono a vibrare e puoi trascinarne una su un'altra per scambiarle (per esempio PIM / ART). Un doppio tocco su una lettera le rimette a posto.

**Icone.** 📌 trascina la puntina su una lettera per fissarla; ↺ ricomincia con le stesse parole; 💾 copia il puzzle in JSON (lettere nell'ordine di sotto, indizi, inizi delle parole, soluzione, e sotto "builder" il link che riapre il builder esattamente in questo stato): incollalo in chat per aggiungerlo ai puzzle del gioco; 🔗 copia il link per giocare il puzzle.

**Soluzioni.** Accanto ad «annulla» il builder cerca fino a 10 griglie complete che tengono tutte le lettere messe e contengono tutte e tre le parole, provando ogni partenza per quelle non ancora messe: dice 0 se così le parole non ci stanno, il numero esatto fino a 9, oppure 10+. Per ora cerca solo soluzioni in cui le parole non si sovrappongono, né tra loro né con se stesse (una parola non ripassa su una sua casella). Con «niente U» scarta anche le parole che girano a U su se stesse (due lettere a tre passi di distanza una accanto all'altra); una parola lunga può comunque toccarsi più avanti. Nelle annotazioni, le lettere delle tre parole in una delle soluzioni sono colorate come la loro parola e le altre lettere della soluzione sono in nero; 🎲 ne mostra un'altra.

**Annotazioni.** Ogni casella vuota mostra le lettere che può ancora avere in almeno una griglia completa. Una casella senza possibilità diventa rossa.

**Indizi.** Le lettere messe sono solo gioco. Trascina la puntina su una lettera per fissarla come indizio; tieni premuta una lettera fissata per toglierle la puntina. Il puzzle è fatto delle caselle iniziali delle parole e degli indizi fissati: il riquadro sotto ne conta le soluzioni, e quando è 1 è pronto.
"""

nbText: """
The builder is a [nimib](https://github.com/pietroppeter/nimib) notebook. Board, tiles and gestures are the game's;
the pencil marks and the solution count come from [puzzlepaw](https://github.com/pietroppeter/puzzlepaw)'s
`parloku/solver`, compiled to JavaScript with the page. The word sets are checked natively while the page is built:
"""

nbCode:
  const wordSets = [
    "ITALIA PASTA ALPI", "AMICA GIOCO MAGIA", "IMPARA PRIMA MATITA", "PAROLE PERLE OPERA",
    "LOGICA GIOCA CALCOLI", "ALBA LUNA NUBE", "CENA PANE PERA", "ESTATE MARE SERATA",
    "CANE PESCE APE", "NERO ROSA ORO", "CANTO NOTE TONO", "PROVA TROVA PORTA"]
  proc lettersOf(words: seq[string]): string =
    for w in words:
      for ch in w:
        if ch notin result: result.add ch
  for s in wordSets:
    let ws = s.split(' ')
    var p: Problem
    let ls = lettersOf(ws)
    for i in 0 ..< min(6, ls.len): p.letters[i] = ls[i]
    for w in ws: p.wordHints.add HintWord(pos: (row: 0, col: 0), word: w)
    let issues = validate(p)
    echo &"{s:<20} letters {ls.len}  ", (if ls.len == 6 and issues.len == 0: "ok" else: $issues)


nbSave
