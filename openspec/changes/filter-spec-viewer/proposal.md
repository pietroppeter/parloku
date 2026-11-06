## Why

The spec viewer shows every spec and every open change on one long page. When we work on one change, a person or an
agent has to scroll past everything else to find it. Pietro, 6 November 2026 (project thread "Filter spec viewer to
chosen changes"): the viewer should be able to show only the changes we want, so an AI can quickly focus on them,
with a static page and URL parameters, documented for people and agents.

## What Changes

- `specs/?change=<name>` shows only that open change; `specs/?spec=<name>` shows only that spec. Each takes a
  comma-separated list, can be repeated, and takes `all`; a name ending in `*` matches by prefix. The two can be
  combined. With no parameter the page shows everything, as before.
- The same parameters work after `#` (`specs/#change=<name>`), for places that drop the query string.
- A filtered page says what it shows, names any name it did not find, links to the whole page, and opens what it
  shows. A spec delta link to a spec that is hidden shows that spec.
- The filter runs in the browser, in Nim compiled to JavaScript. A tool that fetches the page without running
  JavaScript gets the whole page, so the page and `AGENTS.md` tell agents where the plain markdown sources are.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `way-of-working`: the spec viewer can be filtered by link.

## First principles touched
- none (no game screen changes)

## Impact
- `src/specs_page.nim`: the filter, its banner, and a short "Links to a part" section.
- `AGENTS.md`: how to link to a part of the viewer, and what a fetch tool sees.
- Built in the PR from branch `claude/project-thread-rcj0va`.
