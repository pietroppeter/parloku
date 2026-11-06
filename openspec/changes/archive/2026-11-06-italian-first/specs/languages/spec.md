## MODIFIED Requirements

### Requirement: Choosing the language
The game SHALL speak Italian. English is a draft, chosen with `?lang=en` and then remembered; `?lang=it` goes back
to Italian. The browser's language SHALL NOT change it, and there SHALL be no language switch in the menu.

#### Scenario: An Italian browser
- **WHEN** a browser set to Italian opens the game for the first time
- **THEN** the page is in Italian

#### Scenario: A link in English
- **WHEN** the game is opened with `?lang=en` in an Italian browser
- **THEN** the page is in English

#### Scenario: An English browser
- **WHEN** a browser set to English opens the game for the first time, with no `?lang=`
- **THEN** the page is in Italian

### Requirement: Everything in both languages
Every text a player reads SHALL exist in Italian: the game, the rules, the tutorial's explanations, the splash and
the istruzioni page. The English draft SHOULD follow, and MAY lag behind (the istruzioni page is Italian only for
now). Words of the puzzles stay as they are (they are Italian words).

#### Scenario: A tutorial step
- **WHEN** the tutorial explains a forced letter in Italian
- **THEN** the same step has an English sentence naming the same cells and the same reason

#### Scenario: Istruzioni in an English page
- **WHEN** the game is in English and the player taps istruzioni
- **THEN** the istruzioni page opens in Italian
