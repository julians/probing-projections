# 019 Recompute race in the deferred computation

Phase: bug

## Why
`App.createVisualisation` defers the MDS and clustering by 50 ms (`setTimeout`) so the browser can
repaint, but reads `DataWrapper.sampleList` when the timeout fires. Submitting new data within
those 50 ms makes the first timeout run against the new sample list, with an embedding of `null`
→ `TypeError` in `SampleList.calculateProjectionDistanceMatrix`.

## Tasks
- [x] Capture the sample list in the closure, or cancel the pending timeout on a new submit
- [ ] Longer term: run the computation in a Web Worker (also keeps the UI responsive for large
  datasets)

## Notes
Only triggered by a script so far, but large datasets make it more likely. Came in with PR #3.

## Done
Short-term fix: commit “Cancel a pending computation when new data is submitted” (both: the
timeout is cancelled and the sample list is captured). The `TypeError` actually came from
Scatterplot drawing the new samples before their projection existed, reached through 021 and
through clearing the selection lists. Scatterplot now skips drawing until all samples have
positions. Tested with three orders of two submits 10 ms apart: the last submit wins, no errors.
Stays open for the Web Worker.
