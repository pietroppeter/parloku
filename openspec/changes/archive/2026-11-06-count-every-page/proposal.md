## Why

Pietro wants Plausible analytics on every public page of Parloku (6 November 2026), with one Plausible site,
`pietroppeter.xyz`, for all his sites. The snippet lives in one place, but a new page could still leave it out
without anyone noticing.

## What Changes

- The snippet Plausible gives for the site is the `analytics` constant in `src/style.nim`, inside `pageStyle`.
  Pages with their own head import the same constant.
- `src/all.nim` checks every generated page after the build and fails if one of them lacks the snippet.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `way-of-working`: a requirement that every page counts one visit.

## Impact

- `src/style.nim`, `src/all.nim`, the two devlog posts with their own head.
