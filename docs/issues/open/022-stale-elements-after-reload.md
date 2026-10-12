# 022 Old dots and clusters stay in the DOM after loading new data

Phase: bug

## Why
After loading the sample data (36 samples) and then iris (150), the scatterplot has 186
`circle.dot` elements, and the cluster list contains the old clusters next to the new ones
(with opacity 0). Same behaviour before and after 002–004.

## Tasks
- [ ] Check whether it’s visible or affects interaction (hover, brushing on invisible dots?)
- [ ] Probably missing `exit().remove()` calls or stale selections; fix, or let 014/016 fix it

## Notes
Observed 2026-10-12 while testing 004.

## Done
