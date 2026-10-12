# 025 More custom properties, rough dark mode

Phase: idea

## Why
Requested 2026-10-12: turn as many Sass variables as possible into custom properties, and add a
rough dark mode (`prefers-color-scheme`) that keeps the look.

## Tasks
- [ ] Tooltip component (`components/_tooltip.scss`): colours → custom properties; sizes used in
  Sass math (`$tooltip-arrow-width + 2px` etc.) either stay Sass or become `calc()`
- [ ] `$thumbSize`, `$heatmapThumbSize`: custom properties with `calc()`
- [ ] Hard-coded greys/whites in all partials → named custom properties (plot background 95%,
  data entry 88%, textarea, `.control` background, panel borders, density plot fills, legend `.fakePlot`,
  sidebar `h3` #888, dot hover #555, heatmap/cluster line black)
- [ ] Dark values under `@media (prefers-color-scheme: dark)`: black-alpha greys → white-alpha,
  backgrounds mirrored around mid grey. Mirror the halo/line greys (base 91%, far 82%, near 100%
  around the 95% plot background) so that “nearer” and “farther” keep their contrast relations
- [ ] JS colours: heatmap thumbnail canvas (`HeatmapThumbnail.coffee`, black with alpha) and the
  inline distance line strokes (`Scatterplot.coffee` ~600) should read the custom properties,
  and redraw on a `matchMedia` change
- [ ] Icons (`eyeicon.png`, `scalesymbol.png`): `filter: invert(1)` in dark mode
- [ ] Verify light mode unchanged via computed-colour comparison (see agent log for the method)

## Notes
Data colours (category palette and base dots at L=60, diff bars) work on dark backgrounds as they
are.

## Done
