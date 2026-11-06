## ADDED Requirements

### Requirement: A devlog index
`devlog/` SHALL have an index page listing every post newest first, with its date, title and lede, read from the
posts' sources, so a new post needs no entry there; each post's header SHALL link back to it.

#### Scenario: A new post
- **WHEN** a devlog post is added in `src/`
- **THEN** it appears on the devlog index at the next build, with nothing else to edit
