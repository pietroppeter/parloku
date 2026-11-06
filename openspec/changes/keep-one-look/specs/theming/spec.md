## MODIFIED Requirements

### Requirement: Choosing a skin
The game SHALL show Niki (after Niki de Saint Phalle) and SHALL offer the player no skin switch, and it SHALL NOT
remember a skin picked earlier. The ten pastel skins SHALL stay in the code, reachable only with `?skin=<name>`, for
testing and for the styles devlog. The original maiolica skin is retired.

#### Scenario: A link with a skin
- **WHEN** the page is opened with `?skin=tullet`
- **THEN** it shows the Tullet skin

#### Scenario: No switch for the player
- **WHEN** a player opens the game without `?skin=`
- **THEN** the game shows Niki, and nothing on the page lets them pick another skin
