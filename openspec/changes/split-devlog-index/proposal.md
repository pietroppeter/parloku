## Why

The devlog index mixes two kinds of pages. Dated posts tell one step as it happened and are never updated. Other
pages are kept current as the game changes: the specs, how to play, the builder and its how-to, and "How it works",
which is the game's own notebook and is rebuilt with every change to the game. Pietro, 6 November 2026 (project
thread "Split Parloku devlog index like cicak"): split the index like the cicak dev log, living documents first, then
the posts.

## What Changes

- `devlog/` starts with a short table of the living documents: what each one is and when it is updated.
- Below it, the dated posts, newest first, read from their sources as before.
- "How it works" moves from the posts to the living documents. Its header says "living page" instead of a date, like
  the spec viewer.
- The README splits its devlog list the same way.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `way-of-working`: the devlog index lists the living documents before the posts.

## First principles touched
- none (no game screen changes)

## Impact
- `src/devlog_index.nim`: the living documents table, then the posts.
- `src/parloku.nim`: the header of the "How it works" page.
- `README.md`: two lists. Built in the PR from branch `claude/project-thread-wu7c2s`.
