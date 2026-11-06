## Why

Pietro, 6 November 2026, on his iPhone: tapping ↶ or ↷ twice quickly zoomed the page instead of taking back two moves.
iPhone Safari reads two quick taps as a zoom unless the page says otherwise.

## What Changes

- The whole page sets `touch-action: manipulation` (and buttons and links too), so a quick second tap is a tap. Pinch
  zoom keeps working. The board keeps `touch-action: none`, which it already had for dragging.
- Double taps the game listens to (sending a letter back, notes between the letters below) work as before, and no
  longer risk zooming the page.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `player`: a double tap never zooms.

## First principles touched
- Same behaviour in every browser, including iPhone Safari.

## Impact
- `src/style.nim` (`html`, `button`, `.btn`, `a`), `tests/gestures/undo.js` (two quick taps on ↶ with a touchscreen,
  and the touch-action the page reports).
