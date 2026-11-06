## MODIFIED Requirements

### Requirement: Puzzle files
A puzzle SHALL be stored in `data/` as puzzlepaw JSON named `puzzleN-WORD1-WORD2-WORD3.json`, holding the
problem (letters, given letters, word clues with their start cells, 0-based) and its solution. It SHALL also say who
made it (`author`: a GitHub login, or `claude`) and when (`created`: `YYYY-MM-DD`). The game SHALL read these files
at build time and list them in file order.

#### Scenario: The second puzzle
- **WHEN** `data/puzzle2-AMICA-GIOCO-MAGIA.json` is built
- **THEN** the game offers a puzzle with the words AMICA, GIOCO and MAGIA, starting at r1c1, r2c2 and r1c6

#### Scenario: Who made a puzzle
- **WHEN** `data/puzzle4-ESTATE-MARE-SERATA.json` is read
- **THEN** its author is `claude` and it was created on 2026-11-06
