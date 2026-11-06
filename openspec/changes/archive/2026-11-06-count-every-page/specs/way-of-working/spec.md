## ADDED Requirements

### Requirement: Every page counts a visit
Every public page SHALL load Plausible analytics for the site `pietroppeter.xyz`, one Plausible site for all of
Pietro's sites, where Parloku is picked out by hostname (Pietro, 6 November 2026). The snippet SHALL live in one
place, the `analytics` constant in `src/style.nim`, which `pageStyle` puts in every page's head; a page with its own
head SHALL import that constant. It SHALL run only in the top window and only once, so pages framed in other pages
(practice boards, dances, the game pasted into a post) do not count a second visit. The site build (`src/all.nim`)
SHALL fail when a generated page lacks the snippet.

#### Scenario: A new page without the snippet
- **WHEN** a new page in `src/` writes its own head and leaves out `analytics`
- **THEN** `nim c -r -d:release src/all.nim` exits with an error naming that page

#### Scenario: The game inside a post
- **WHEN** a devlog post shows the game page in a frame
- **THEN** Plausible loads once, for the post
