# 012 End-to-end smoke test of the main flow (Playwright)

Phase: 1 · Safety net

## Why
The UI has no tests, and the Svelte port (014/015) changes all of it.

## Tasks
- [ ] Set up Playwright against `pnpm dev` (or `pnpm preview`)
- [ ] Load the sample data, check dots and dimensions render, no console errors
- [ ] Paste iris (with labels), recompute metric and non-metric, check the three classes appear
- [ ] Set clusters to 3, toggle errors and dendrogram
- [ ] Brush samples, create a selection with “+”, remove it
- [ ] Hover a dot and check the tooltip

## Notes
This is what was checked by hand in the browser during 002–004. Wait for the initial render
before submitting new data; submitting within ~50 ms triggers 019.

## Done
