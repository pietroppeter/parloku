## ADDED Requirements

### Requirement: Explaining a puzzle step by step
The spiega page SHALL take a puzzle as `?p=<code>` (or a pasted code or play link) and explain it with moves a person
can check, tried in this order: follow a word (its next letter has one cell left next to the previous one, maybe after
ruling out a neighbour from which the word can't be finished or would take another word's cells), only place (a letter
with one cell left in a row, column or box), only letter (a cell with one letter left), and eliminations. It SHALL never
guess: when no move works it SHALL stop and say so. It SHALL also say when the puzzle has no solution or more than one.

#### Scenario: Puzzle 3 without a guess
- **WHEN** the page explains puzzle 3 (PAROLE · PERLE · OPERA)
- **THEN** it solves it without a guess in 30 moves: 13 follow the word and 17 only place

#### Scenario: A puzzle with two solutions
- **WHEN** the page gets puzzle 1's words with no given letters
- **THEN** it says the puzzle has more than one solution

### Requirement: The gallery
Each move SHALL be a slide: the board after the move, the letter just placed with a thick edge, the reason shaded (a
row, column or box, or the word's path so far), every word's container as the game draws it (on the spiega page also its tinted start cell and the eyes on its head; the dated devlog post keeps its first look), the words above the board
with round letters lit as they are spelled, the pencil marks of the empty cells, and the reason in words. The slides
SHALL scroll sideways; a tap SHALL go to the next slide, a tap on the left third to the previous one.

#### Scenario: Tapping through
- **WHEN** the player taps the gallery five times on its right side, then once on its left side
- **THEN** it shows slide 4
