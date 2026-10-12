# 008 Decide on the PCA/t-SNE options

Phase: 0 · Clean up

## Why
`DataEntry.html` has commented-out radio buttons for PCA and t-SNE. The Python server supported
both; the in-browser version (001) only does MDS, and `drType` is now ignored.

## Tasks
- [x] Decide: remove the commented-out options and `drType`, or implement them (implement)
- [x] PCA, as “Classical MDS / PCA”
- [ ] t-SNE: pick a library or port, check the error displays, add perplexity control

## Notes
The error displays (stress, distance errors) are designed around MDS; check whether they make
sense for t-SNE before adding it.

## Done

Classical MDS and PCA give the same configuration here, because the distances are euclidean on
the normalised vectors. Verified numerically to 1e-14, so it's one option and not two.

t-SNE findings (2026-10-12):
- Libraries: `@saehrimnir/druidjs` (maintained, many DR methods, but LGPL-3.0 and 4.5 MB
  unpacked); `@keckelt/tsne` (MIT, 17 kB TypeScript port of Karpathy’s tsnejs, last release 2022);
  `tsne-js` (Apache, ndarray dependencies, last release 2022). Porting tsnejs to CoffeeScript
  (~300 lines) would work the same way as the SMACOF port.
- Exact t-SNE is O(n²) per iteration with about 1000 iterations. That is instant for the samples
  here and a few seconds at n≈1000. It is iterative, so it should run step by step (animated, or in
  a Worker) instead of blocking like SMACOF does now (see 019).
- Perplexity must stay below about n/3 (the 36-row sample allows about 10), so it needs a control.
  It is stochastic, so it needs a seed.
- The open question is the thesis's error displays. t-SNE preserves neighbourhoods, not
  distances, so stress and the distance error display will always look bad and mislead. It would
  need neighbourhood-based errors (e.g. trustworthiness/continuity, kNN overlap), or the error
  display has to be disabled for t-SNE.

Done so far: commit “Offer classical MDS / PCA as a projection type”. This also fixes Recompute
doing nothing on data with `mds:x`/`mds:y` columns.

