# puzzle-format Specification

## Purpose
How puzzles are stored and shared: as puzzlepaw JSON files in `data/`, and as short codes that fit in a link.

## Requirements

### Requirement: Puzzle files
A puzzle SHALL be stored in `data/` as puzzlepaw JSON named `puzzleN-WORD1-WORD2-WORD3.json`, holding the
problem (letters, given letters, word clues with their start cells, 0-based) and its solution. The game SHALL read
these files at build time and list them in file order.

#### Scenario: The second puzzle
- **WHEN** `data/puzzle2-AMICA-GIOCO-MAGIA.json` is built
- **THEN** the game offers a puzzle with the words AMICA, GIOCO and MAGIA, starting at r1c1, r2c2 and r1c6

### Requirement: Puzzle codes
A puzzle SHALL also be written as a code `LETTERS_GIVENS_WORDS`, the format puzzlepaw uses: givens are
`<row><col><letter>` and words `<row><col><word>`, 0-based and separated by dots. Decoding SHALL ignore case,
and a code SHALL be valid only with six distinct letters and every given and word inside the grid and spelled
with those letters.

#### Scenario: The first puzzle as a code
- **WHEN** puzzle 1 is encoded
- **THEN** the code is `AILPST_51S.23L.04P_00ITALIA.20PASTA.40ALPI`

#### Scenario: A letter that is not in the puzzle
- **WHEN** a code has the given `00Z` and Z is not one of its letters
- **THEN** the code is not valid and the game ignores it

### Requirement: Links to a puzzle
Any puzzle SHALL be playable from a link with `?p=<code>`, wherever `p=` is in the query string. A link to a
puzzle the game doesn't ship SHALL add it to the puzzle choices.

#### Scenario: A link with other options first
- **WHEN** the page is opened with `?lang=it&p=AILPST_51S.23L.04P_00ITALIA.20PASTA.40ALPI`
- **THEN** it opens in Italian on puzzle 1
