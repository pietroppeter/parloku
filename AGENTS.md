# Working on Parloku

Notes for coding agents (and people) changing this repository. How the game behaves is in `openspec/specs/`
(rendered at `specs/`); how it is built is in README.md. This file holds the working rules that are easy to miss.

## Behaviour lives in the specs

- Every agreed behaviour is a requirement with scenarios in `openspec/specs/`. New work starts as an OpenSpec change
  in `openspec/changes/` (`/opsx:propose`), is built in a PR (`/opsx:apply`), and is archived when it ships
  (`/opsx:archive`). `openspec/config.yaml` has the rules for proposals, specs and archiving.
- A playtest finding becomes a scenario before it is fixed. Gameplay scenarios are ```drag blocks (see the
  `way-of-working` spec); `nim r tools/specdrag.nim` plays them on the built `index.html`
  (build `src/parloku.nim` first; needs Node and Playwright; CI runs them while it builds the specs page). Scenarios in the specs
  must pass before a merge; a change's own scenarios may fail until it is built.
- The pages are not committed: CI builds them all (`src/all.nim`) and plays the scenarios while it builds the spec
  page, so a failing scenario in the specs turns the build red. Locally: `nim c -r -d:release src/all.nim`.

- Two kinds of pages about the specs: `specs/` (`src/specs_page.nim`) is the living spec viewer, rebuilt by CI from
  `openspec/` on every push, and linked from the README. A devlog post (like `devlog/openspec/`) is dated: it tells one
  step as it happened, and is not updated when the specs change. A post that shows scenario animations keeps frozen
  runs next to its source (as `src/devlog_openspec/before.json` and `after.json`) instead of replaying the current game.

- A link can show only part of the spec viewer: `specs/?change=<name>` for open changes, `specs/?spec=<name>` for
  specs (comma-separated, repeatable, `all`, `name*` for a prefix; the same after `#`, as `specs/#change=<name>`, where
  a link drops its query). Give Pietro such a link, not the whole page, when a change is under review. The filter runs
  in the browser, so it works when you open the page in Playwright; a fetch tool that does not run JavaScript gets the
  whole page. To read one spec or change, read its markdown in `openspec/` (or
  `https://raw.githubusercontent.com/pietroppeter/parloku/<branch>/openspec/...`). The `way-of-working` spec has the
  rules and the page's "Links to a part of this page" has examples.

## Previews and PRs

- Show Pietro a published preview (an artifact) before asking to merge; he reviews on his phone.
- Nothing goes to `main` without his go. One clean PR per change; keep the other branches.
- Keep the PR description in sync with the branch.

## Pages

- Every page is a nimib notebook in `src/` that writes a standalone HTML file. A new devlog post goes in
  `devlog/<slug>/` with a line in the README devlog list (link its Pages URL, https://pietroppeter.github.io/parloku/devlog/<slug>/, since the HTML is not in the repo); a garden page (an idea still growing) in `garden/<slug>/`.
