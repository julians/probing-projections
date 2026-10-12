# 023 Idea: start SMACOF from classical MDS

Phase: idea

## Why
SMACOF currently starts from 10 random configurations and keeps the best. Starting from the
classical (Torgerson) MDS solution instead gives a reproducible result, usually in fewer iterations.

## Tasks
- [x] Implement classical MDS without numeric.js (top two eigenvectors, e.g. power iteration)
- [x] Use it as the SMACOF starting configuration, compare stress and speed with the random starts

## Notes
Related: 007 removes the old numeric.js-based implementation.

## Done
Commit “Start SMACOF from the classical MDS solution”. Jacobi rather than power iteration, run on
the smaller of the d×d scatter and n×n Gram matrices (identical result, checked to 1e-14).
On the OECD sample and on synthetic sets of up to 200×10 points, one classical start reached the
same stress as the best of 10 random starts (±0.5%) and ran 20–60× faster (200×10 non-metric:
5.4 s → 0.17 s). A single random start can be much worse (OECD metric: 36.9 vs 22.6).
`init: "random"` keeps the old behaviour.
