# way-of-working Specification

## Purpose
How Parloku is made: pages that explain themselves, a devlog and a digital garden, previews before merges, and
OpenSpec to keep every agreed behaviour written down and checked.

## Requirements

### Requirement: Pages are explainers
Every page (the game, the builder, each post) SHALL be a nimib notebook whose source is the page: the code that runs
is the code shown, run natively at build time for the printed outputs and compiled to JavaScript for the browser.
A page SHALL be a complete standalone HTML file served by GitHub Pages, with nothing loaded from claude.ai.

#### Scenario: A new page
- **WHEN** a page is added
- **THEN** it has a `src/<name>.nim` notebook that writes it, and a build line in the README

### Requirement: Devlog and garden
Work SHALL be written up in two ways. The devlog (development log, `devlog/<slug>/`) SHALL hold dated posts, each about
one step in how the game evolves, listed newest first in the README. The digital garden (`garden/<slug>/`, after
Maggie Appleton's idea) SHALL hold articles that stand apart from the posts: they are published before they are
complete, and they are come back to and grown over time. How the garden works in detail is still being shaped.

#### Scenario: An idea that keeps growing
- **WHEN** a topic (like tiles that divide like cells) gets explored over several sessions
- **THEN** it lives as one garden article that is updated each time, rather than as a series of dated posts

#### Scenario: A step that ships
- **WHEN** a change reaches the game
- **THEN** a dated devlog post tells what changed and why, and can link the garden articles behind it

### Requirement: English for development
Specs, proposals, code, comments, commits, PRs and the devlog SHALL be written in English, the language of development
and iteration, even though the game itself speaks Italian first and Pietro often writes in Italian or mixes the two.

#### Scenario: A request in Italian
- **WHEN** Pietro asks for a change in Italian
- **THEN** the change's proposal, specs and PR are written in English

### Requirement: Preview first, one clean PR
A change SHALL be shown to Pietro as a published preview (an artifact, which opens on a phone) before anything is
merged. Nothing SHALL be pushed to `main` until Pietro says so, and each change SHALL arrive as one clean PR. Old
branches SHALL be kept.

#### Scenario: A gesture fix
- **WHEN** a gesture is fixed
- **THEN** Pietro gets a preview link to try it on his phone, and the PR waits for his go

### Requirement: Behaviour lives in the specs
Every agreed behaviour SHALL be written in `openspec/specs/` as a requirement with scenarios. New work SHALL start as
an OpenSpec change (`openspec/changes/<name>/`: proposal, spec deltas, tasks), and when it ships the change SHALL be
archived so its deltas merge into the specs. A playtest finding SHALL become a scenario before it is fixed.

#### Scenario: A playtest bug
- **WHEN** a playtester finds that moving a word's last letter copies it
- **THEN** the case is written as a drag scenario in a change, it fails, the fix makes it pass, and archiving moves it
  into the specs

### Requirement: Scenarios that run
A gameplay scenario SHALL be written as a ```drag block where it can be (a start board, a gesture, an end board or an
outline), and `nim r tools/specdrag.nim` SHALL play every one of them on the built game page
(headless Chromium, real pointer events). CI SHALL play them on every push and pull request while it builds the
spec page, and scenarios in the specs SHALL pass before a PR is merged; scenarios in an open change MAY fail until it is built. The spec viewer
(`specs/`) SHALL play each one as an animation with its result.

#### Scenario: A spec scenario breaks
- **WHEN** a change to `src/parloku.nim` makes a scenario in `openspec/specs/` fail
- **THEN** `tools/specdrag.nim` exits with an error naming the scenario, and shows the expected and the actual board
