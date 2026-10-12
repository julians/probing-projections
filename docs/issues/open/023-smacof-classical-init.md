# 023 Idea: start SMACOF from classical MDS

Phase: idea

## Why
SMACOF currently starts from 10 random configurations and keeps the best. Starting from the
classical (Torgerson) MDS solution instead gives a reproducible result, usually in fewer iterations.

## Tasks
- [ ] Implement classical MDS without numeric.js (top two eigenvectors, e.g. power iteration)
- [ ] Use it as the SMACOF starting configuration, compare stress and speed with the random starts

## Notes
Related: 007 removes the old numeric.js-based implementation.

## Done
