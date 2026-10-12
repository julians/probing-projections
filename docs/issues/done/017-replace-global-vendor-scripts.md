# 017 Replace science.js, Sylvester and Modernizr

Phase: 4 · Current libraries for the visualisations

## Why
These three only work as globals and are loaded with plain script tags from
`web/app/public/vendor`. They are used very little.

## Tasks
- [x] science.js: `stats.mean`, `stats.quantiles`, `stats.kde`, `stats.bandwidth.nrd` → d3-array
  or a few lines of own code
- [x] Sylvester: four vector operations (`$V`) in `Scatterplot` → own helpers
- [x] Modernizr: `Modernizr.touch` and the classes on `<html>` → a direct feature check
  (check which `.touch`/`.no-touch` classes the styles use)
- [x] Remove `web/app/public/vendor`

## Notes

## Done
Commit “Replace science.js, Sylvester and Modernizr with own code”.
- `scripts/Stats.coffee` is a 1:1 port rather than d3-array. d3's `mean`/`quantile` skip null/NaN,
  science.js didn't, and its `quantiles` returns arrays that callers rely on (→ 024). Bit-identical
  to science.js on 1800 randomised checks. The bandwidth used was `nrd0`, not `nrd`.
- No styles used Modernizr's classes; the `supportsFeature` helper was never imported. Removed both,
  plus the IE conditional comments on `<html>`.
- `web/app/public` is gone entirely (vendor was all it held).
