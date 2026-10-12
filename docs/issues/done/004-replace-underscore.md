# 004 es-toolkit and native JS instead of Underscore

Phase: migration

## Why
Underscore is old and was used for ~60 calls that mostly have native equivalents.

## Tasks
- [x] Native replacements (`Array.isArray`, `Object.keys/values/assign/entries`, `filter`,
  `map`, `includes`, `flat`)
- [x] es-toolkit for `uniq`, `difference`, `sortBy`, `minBy`, `maxBy`, `throttle`, `mean`, `median`
- [x] Rewrite the three `_.chain()` calls, remove the `underscore.math` mixin
- [x] `_.uniqueId()` → `Utils.uniqueId()` (same sequential string ids)

## Notes
`_.values(null)` returns `[]`, `Object.values(null)` throws: `DimensionDisplay` now guards
`@densityPlots`, which is unset until data is loaded.

## Done
`ddd412e`. Compared side by side in the browser with the previous commit: same behaviour.
