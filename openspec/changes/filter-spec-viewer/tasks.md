## 1. Decide

- [x] 1.1 Pietro: let the spec viewer show only chosen changes, by URL parameters on the static page (6 Nov 2026)

## 2. Apply

- [x] 2.1 Read `change` and `spec` from the query string and the hash in `src/specs_page.nim` (Nim compiled to JS)
- [x] 2.2 Hide what is not chosen, open what is, and show a banner with a link to the whole page
- [x] 2.3 Document the parameters on the page and in `AGENTS.md`, with the plain sources for agents
- [x] 2.4 Run `nim r tools/specdrag.nim` and rebuild specs/ (src/specs_page.nim)
