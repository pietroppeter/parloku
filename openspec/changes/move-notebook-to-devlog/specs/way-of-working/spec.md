## MODIFIED Requirements

### Requirement: Pages are explainers
Every page SHALL be a nimib notebook that writes a complete standalone HTML file served by GitHub Pages, with nothing
loaded from claude.ai. A page whose job is to explain (each devlog post, each garden article) SHALL show the code
that runs: run natively at build time for the printed outputs and compiled to JavaScript for the browser. The game
and the builder are pages to use; how they are built is told in devlog posts.

#### Scenario: A new page
- **WHEN** a page is added
- **THEN** it has a `src/<name>.nim` notebook that writes it, and a build line in the README
