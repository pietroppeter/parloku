## MODIFIED Requirements

### Requirement: Mistakes are cheap
Any change to the board SHALL be undoable, and the one action that wipes the board SHALL be undoable right after it,
without a confirmation in the way.

#### Scenario: Reset
- **WHEN** the player taps reset by mistake
- **THEN** they can get their board back with one tap
