## ADDED Requirements

### Requirement: A double tap never zooms
On every page of the game, two quick taps SHALL be two taps, never a page zoom, in every browser including iPhone
Safari (Pietro, 6 November 2026: tapping ↶ twice zoomed the page instead of taking back two moves). Pinch zoom SHALL
keep working, so the page can still be enlarged on purpose.

#### Scenario: Two quick undos
- **WHEN** the player has placed three letters, slides the menu down and taps ↶ twice in quick succession
- **THEN** two letters go back below, and the page keeps its size

#### Scenario: A double tap on the board
- **WHEN** the player double taps a placed letter
- **THEN** the letter goes back below, and the page keeps its size
