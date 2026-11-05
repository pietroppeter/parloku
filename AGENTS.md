# Working on Parloku

Notes for coding agents (and people) changing this repository. How the game behaves is in `openspec/specs/`
(rendered at `specs/`); how it is built is in README.md. This file holds the working rules that are easy to miss.

## Behaviour lives in the specs

- Every agreed behaviour is a requirement with scenarios in `openspec/specs/`. New work starts as an OpenSpec change
  in `openspec/changes/` (`/opsx:propose`), is built in a PR (`/opsx:apply`), and is archived when it ships
  (`/opsx:archive`). `openspec/config.yaml` has the rules for proposals, specs and archiving.
- A playtest finding becomes a scenario before it is fixed. Gameplay scenarios are ```drag blocks (see the
  `way-of-working` spec); `nim r tools/specdrag.nim` runs them against `src/parloku.nim`. Scenarios in the specs
  must pass before a merge; a change's own scenarios may fail until it is built.
- After changing specs or the game, rebuild the spec page: `nim c -r -d:release src/specs_page.nim`.

## Previews and PRs

- Show Pietro a published preview (an artifact) before asking to merge; he reviews on his phone.
- Nothing goes to `main` without his go. One clean PR per change; keep the other branches.
- Keep the PR description in sync with the branch.

## Pages

- Every page is a nimib notebook in `src/` that writes a standalone HTML file. A new devlog post goes in
  `devlog/<slug>/` with a line in the README devlog list; a garden page (an idea still growing) in `garden/<slug>/`.
