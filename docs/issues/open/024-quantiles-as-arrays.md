# 024 Quantiles are one-element arrays

Phase: bug

## Why
`Stats.quantiles` (like science.js before it) returns an array per call, and
`QuantitativeDimension.getQuantiles` stores `quantiles(values, [q])` per quantile. So its result
is `[[q25], [q50], [q75]]`, and callers like `DensityDisplay` pass `[[v]]` to scales and
arithmetic, relying on JavaScript's array-to-number coercion. It works, but only by accident.

## Tasks
- [ ] Store `quantiles(values, [q])[0]` in `getQuantiles` and adapt the callers
  (`DensityDisplay.getOffsetForQuantile`, `getDiffBarColour`, the diff bar and quantile lines)
- [ ] Check the density plots and tooltips render the same

## Notes
Found while replacing science.js (017). Kept out of that change so that it stayed a pure port.

## Done
