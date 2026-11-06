## ADDED Requirements

### Requirement: Links to a part of the spec viewer
The spec viewer (`specs/`) SHALL show only some specs and open changes when its link says so, so a person or an agent
can focus on the work at hand. `change=<names>` SHALL choose open changes and `spec=<names>` SHALL choose specs; names
are comma-separated, a parameter MAY be repeated, `all` SHALL choose every one of its kind, and a name ending in `*`
SHALL match by prefix. The parameters SHALL work in the query string (`specs/?change=<name>`) and after `#`
(`specs/#change=<name>`). When one kind is chosen and the other is not named, only the chosen kind SHALL show. A
filtered page SHALL say what it shows, name any name it did not find, link to the whole page, and open what it shows.
With no parameter the page SHALL show everything. A link to a part, clicked on the page, SHALL filter it in place. The filter runs in the browser; the page and `AGENTS.md` SHALL say so,
and SHALL point agents that fetch pages without running JavaScript to the markdown sources in `openspec/`.

#### Scenario: One change
- **WHEN** someone opens `specs/?change=keep-one-look`
- **THEN** the page shows only the change keep-one-look, opened, under a note that says so and links to the whole page

#### Scenario: A change and the spec it touches
- **WHEN** someone opens `specs/?change=keep-one-look&spec=theming`
- **THEN** the page shows that change and the theming spec, and nothing else

#### Scenario: A misspelled name
- **WHEN** someone opens `specs/?change=keep-one-lok`
- **THEN** the note says that keep-one-lok was not found, and links to the whole page

#### Scenario: An agent that fetches the page
- **WHEN** an agent reads the page with a tool that does not run JavaScript
- **THEN** it gets the whole page, and near the top it finds how to read one change or spec as markdown in `openspec/`
