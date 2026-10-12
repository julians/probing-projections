# 011 Unit tests for the computation (Vitest)

Phase: 1 · Safety net

## Why
No tests exist, and phases 2–4 rewrite most of the code. The computation is pure and easy to test.

## Tasks
- [ ] Set up Vitest (it can reuse the CoffeeScript plugin from `vite.config.js`)
- [ ] `MDS.smacof`: metric and non-metric, deterministic with a fixed seed, stress decreases
- [ ] `HierarchicalCluster.ward`: tree shape and stable labels for k → k+1 on a small dataset
- [ ] CSV parsing → dimensions (quantitative, binary, the `Class` column, `mds:x`/`mds:y`)
- [ ] Distance error / stress calculations in `SampleList`
- [ ] Optionally: compare SMACOF and Ward results against scikit-learn output for iris
  (generate once, store as fixture)

## Notes

## Done
