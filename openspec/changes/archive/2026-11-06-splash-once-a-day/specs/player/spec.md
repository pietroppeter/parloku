## MODIFIED Requirements

### Requirement: The page opens on the game
The page SHALL open straight on a playable puzzle, and show only the game (see `play-screen`). On a day's first visit
it SHALL show the daily splash, which can be skipped (`?nosplash`) or shown again (`?splash=first`). Later visits on
the same day SHALL open straight on the game, without the splash; the first-visit splash for a new player SHALL show
until it is closed.

#### Scenario: First visit of the day
- **WHEN** a player opens the page for the first time today
- **THEN** the splash greets them, and closing it shows the puzzle ready to play

#### Scenario: Back the same day
- **WHEN** a player who has already seen today's splash opens the page again, or follows a link to a puzzle
- **THEN** the puzzle shows at once, with no splash
