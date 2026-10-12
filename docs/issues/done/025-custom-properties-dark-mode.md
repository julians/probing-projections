# 025 More custom properties, rough dark mode

Phase: idea

## Why
Requested 2026-10-12: turn as many Sass variables as possible into custom properties, and add a
rough dark mode (`prefers-color-scheme`) that keeps the look.

## Tasks
- [x] Tooltip component (`components/_tooltip.scss`): colours → custom properties; sizes used in
  Sass math (`$tooltip-arrow-width + 2px` etc.) either stay Sass or become `calc()`
- [x] `$thumbSize`, `$heatmapThumbSize`: custom properties with `calc()`
- [x] Hard-coded greys/whites in all partials → named custom properties (plot background 95%,
  data entry 88%, textarea, `.control` background, panel borders, density plot fills, legend `.fakePlot`,
  sidebar `h3` #888, dot hover #555, heatmap/cluster line black)
- [x] Dark values under `@media (prefers-color-scheme: dark)` (see Done for the rule)
- [x] JS colours: heatmap thumbnail canvas (`HeatmapThumbnail.coffee`, black with alpha) and the
  inline distance line strokes (`Scatterplot.coffee` ~600) should read the custom properties,
  and redraw on a `matchMedia` change
- [x] Icons: replaced by SVG (eye as CSS mask coloured with `--ink`, scale symbol inline with custom properties)
- [x] Verify light mode unchanged via computed-colour comparison (see agent log for the method)

## Notes
Data colours (category palette and base dots at L=60, diff bars) work on dark backgrounds as they
are.

## Done
Three commits: custom properties (light mode identical), dark mode, SVG icons.
- No Sass variables are left. Sizes Sass used to compute with are `calc()` now; colours are named
  by role and built around `--ink`/`--paper`. JS-drawn colours read them via `Utils.cssVar`.
- Dark mode rule, after feedback from Julian: surfaces keep their light-mode order. What is
  further in front (plot, tooltips, controls, “nearer” halos) is lighter, recessed things are
  darker; only ink (text, lines, data marks, the scale symbol) is inverted. A first version
  mirrored all surfaces, which made the plot darker than the page and “nearer” halos black.
- Verified: in light mode, the computed colours, sizes and positions of every element in five UI states
  and the canvas pixels are identical to before (only the two icons differ, as intended). Dark mode
  was checked visually, including a live theme switch (thumbnails redraw black ↔ white).
- Julian's original SVG/PNG exports with spaces in their names were left untracked in
  `web/app/images`; `eye icon.svg` became `eyeicon.svg`, and the scale symbol is inlined.

