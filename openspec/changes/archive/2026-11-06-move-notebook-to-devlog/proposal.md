## Why

The game page is still the nimib notebook that explains how the game is built (the model, the rules as code, the
logical path, the drag spec, the runtime). Since #13 the page shows only the game, so nobody can read it. Pietro,
6 November 2026: move it to a devlog post.

## What Changes

- A new devlog post, `devlog/how-it-works/` (from `src/devlog_how_it_works.nim`), takes the explanation and the code
  shown with it. It embeds the game, like the other posts.
- `index.html` keeps only the game. The code still lives in `src/parloku.nim`, and the post shows it.
- The README devlog list gets the post.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `play-screen`: no hidden notebook in the game page.
- `way-of-working`: the game page is the game, and its explainer is a devlog post.

## First principles touched
- One job per piece: the game page plays, the post explains.

## Impact
- `src/parloku.nim`: the prose and the shown code blocks move out, or the post reads them from the game's source.
- New `src/devlog_how_it_works.nim` and `devlog/how-it-works/`. With CI (#18) the post is picked up automatically.
