## ADDED Requirements

### Requirement: Sharing a solved game
Under Evviva! a 📤 condividi button SHALL share a text that tells how the game went without telling where any letter
goes: on a phone through the share sheet, elsewhere by copying it. Every letter put on the board and every letter sent
back below (by a double tap, by ↶ undo, by a snake stepping back) SHALL be one move; moving a snake's head SHALL be one
move; notes SHALL not be moves. The banner SHALL show the same count. The text SHALL be: a first line with
`Parloku`, the puzzle's number, 🥳 and the dance seen (🌊 ripples, 🐍 snakes, 🪀 letters), the moves, the time, and ⭐
when the moves are as many as the empty cells; then one ball per move, six to a line; then a link to the puzzle. A move
SHALL be 🔴, 🟢 or 🔵 (the colour of the first, second or third word) when it put down, for the last time, a letter of
that word on the solved board, ⚫ when it sent a letter back, and ⚪ otherwise. After 48 moves the text SHALL show the
first seven lines and then `… +N`, the moves left out. The moves and the dance SHALL be saved with the board.

#### Scenario: A clean game
- **WHEN** the player solves puzzle 1 putting each of its 33 letters down once, and taps 📤 condividi
- **THEN** the text starts with `Parloku 1 🥳`, the dance, `33 mosse` and ⭐, has 6 red, 5 green, 4 blue and 18 white
  balls on six lines, and ends with the link `?p=1`

#### Scenario: A letter taken back
- **WHEN** the player takes a letter back with ↶ and puts it again with ↷ before solving
- **THEN** the share has a ⚫ where the letter went back, two more moves, and no ⭐

#### Scenario: A long game
- **WHEN** the player solves a puzzle in 53 moves
- **THEN** the share shows seven lines of balls and then `… +11`

#### Scenario: After a reload
- **WHEN** the player reloads a solved puzzle and taps 📤 condividi
- **THEN** the text is the same as before the reload, with the same dance

### Requirement: A puzzle by its number
A link with `?p=` and a number SHALL open that puzzle of the menu (`?p=1` is the first). A full puzzle code after
`?p=` SHALL keep working.

#### Scenario: The short link
- **WHEN** someone opens the game with `?p=2`
- **THEN** the second puzzle of the menu is on the board
