## MODIFIED Requirements

### Requirement: The tutorial
The 🎓 tutorial SHALL walk the first puzzle along the logical path (see `logical-path`), asking for the next step
after every drop and explaining it. It SHALL fit one phone screen like the game: its messages SHALL sit on
semi-transparent, white-ish blobs over the play area, and a blob SHALL NOT cover the cells, the letter or the clue the
current step is about; the player MAY drag a blob aside, and it stays there. Before it starts it SHALL warn that it
solves the first puzzle (a spoiler). It SHALL teach the gestures as they come up (a double tap on a sure cell,
stretching a word from its last letter, a double tap to take a letter back), in full the first time and by name after.
It opens with `?tutorial`, from the first lesson, and from a link on the istruzioni page.

#### Scenario: Starting the tutorial
- **WHEN** the player opens `?tutorial`
- **THEN** the first puzzle starts with the coach asking for ITALIA's first letter

#### Scenario: The tutorial on an iPhone 13
- **WHEN** the tutorial shows any step on an iPhone 13
- **THEN** the clues, the board and the six letters are where they are in the game, and the letters end above 664 px

#### Scenario: A blob out of the way
- **WHEN** a step asks for I at r1c1
- **THEN** the step's blob covers neither r1c1, nor the I below the board, nor the ITALIA clue
