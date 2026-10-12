# 024 Quantiles are one-element arrays

Phase: bug

## Why
`Stats.quantiles` (like science.js before it) returns an array per call, and
`QuantitativeDimension.getQuantiles` stores `quantiles(values, [q])` per quantile. So its result
is `[[q25], [q50], [q75]]`, and callers like `DensityDisplay` pass `[[v]]` to scales and
arithmetic, relying on JavaScript's array-to-number coercion. It works, but only by accident.

## Tasks
- [x] Store `quantiles(values, [q])[0]` in `getQuantiles` and adapt the callers
  (`DensityDisplay.getOffsetForQuantile`, `getDiffBarColour`, the diff bar and quantile lines)
- [x] Check the density plots and tooltips render the same

## Notes
Found while replacing science.js (017). Kept out of that change so that it stayed a pure port.

## Done
Commit “Return quantiles as numbers instead of one-element arrays”. In passing: `getQuantiles`
cached with a truthiness check, so a quantile of 0 was recomputed every time (now `of`), and the
0.5 quantile in `DensityDisplay` was called `mean`, though it is the median. Verified with a
before/after DOM digest (`git stash`) of quantile lines, diff bars, markers and tooltip
offsets/colours across several hovers and a selection: identical.
