# languages Specification

## Purpose
Parloku speaks English and Italian: how the language is chosen and what must exist in both.

## Requirements

### Requirement: Choosing the language
The pages SHALL speak English and Italian, chosen with the EN / IT switch or `?lang=`, then the last choice, then the
browser's language.

#### Scenario: An Italian browser
- **WHEN** a browser set to Italian opens the game for the first time
- **THEN** the page is in Italian

#### Scenario: A link in English
- **WHEN** the game is opened with `?lang=en` in an Italian browser
- **THEN** the page is in English

### Requirement: Everything in both languages
Every text a player reads SHALL exist in both languages: the game, the rules, the tutorial's explanations, the
splash and the how-to-play page. Words of the puzzles stay as they are (they are Italian words).

#### Scenario: A tutorial step
- **WHEN** the tutorial explains a forced letter in Italian
- **THEN** the same step has an English sentence naming the same cells and the same reason
