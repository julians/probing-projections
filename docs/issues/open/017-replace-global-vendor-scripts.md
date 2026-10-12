# 017 Replace science.js, Sylvester and Modernizr

Phase: 4 · Current libraries for the visualisations

## Why
These three only work as globals and are loaded with plain script tags from
`web/app/public/vendor`. They are used very little.

## Tasks
- [ ] science.js: `stats.mean`, `stats.quantiles`, `stats.kde`, `stats.bandwidth.nrd` → d3-array
  or a few lines of own code
- [ ] Sylvester: four vector operations (`$V`) in `Scatterplot` → own helpers
- [ ] Modernizr: `Modernizr.touch` and the classes on `<html>` → a direct feature check
  (check which `.touch`/`.no-touch` classes the styles use)
- [ ] Remove `web/app/public/vendor`

## Notes

## Done
