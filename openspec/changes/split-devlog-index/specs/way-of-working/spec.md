## MODIFIED Requirements

### Requirement: A devlog index
`devlog/` SHALL have an index page that lists the living documents first and then every post newest first. A living
document is a page kept up to date as the game changes (the spec viewer, how to play, the builder and its how-to, and
"How it works", the game's own notebook); the index SHALL say what each one is and when it is updated, and its header
SHALL say "living page" instead of a date. Posts are dated and are not updated after the fact; the index SHALL list
each with its date, title and lede, read from the posts' sources, so a new post needs no entry there. Each post's
header SHALL link back to the index.

#### Scenario: A new post
- **WHEN** a devlog post is added in `src/`
- **THEN** it appears among the posts on the devlog index at the next build, with nothing else to edit

#### Scenario: A new living document
- **WHEN** a page that is kept current is added
- **THEN** it gets a row in the living documents table of `src/devlog_index.nim`, and never appears among the dated posts
