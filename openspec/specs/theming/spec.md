# theming Specification

## Purpose
How Parloku looks: CSS skins after artists and illustrators, swapped without touching the game code.

## Requirements

### Requirement: The view only names classes
The Nim code that draws the board SHALL only name classes (`g0`…`g5` for letters, `w0`…`w2` for words, `ca`/`cb`
for cells, `boxline`, …) and SHALL draw every shape a skin may pick (square, rounded, round, a blob per letter). A skin
SHALL be CSS only: palette, fonts and which tile shape shows.

#### Scenario: A new skin
- **WHEN** a skin is added to `src/style.nim`
- **THEN** no file but `src/style.nim` changes, and the board, tiles and outlines follow it

### Requirement: Choosing a skin
The skin SHALL be chosen with the switch below the game or with `?skin=<name>`, and remembered in the browser.
Niki (after Niki de Saint Phalle) SHALL be the default for now. The ten pastel skins and the original maiolica SHALL
stay available.

#### Scenario: A link with a skin
- **WHEN** the page is opened with `?skin=tullet`
- **THEN** it shows the Tullet skin

### Requirement: Colour means letter
In every skin each letter SHALL have its own colour, used for its tiles, its stack and its spelled letters on the
clue cards, and nowhere else; each word SHALL have its own colour for its card, start mark and outline. A broken rule
SHALL be shown by motion (the clashing letters roll), not by a colour.

#### Scenario: A clash in the Niki skin
- **WHEN** two A share a row
- **THEN** both roll, and no colour on the board changes

### Requirement: Readable letters
A skin SHALL keep the letter on every tile readable against the tile's colour and the six tile colours apart from each
other; the skins devlog computes contrast and colour distance at build time for this.

#### Scenario: A pale tile
- **WHEN** a skin gives a tile a colour too close to its letter's ink
- **THEN** the skins devlog build flags it
