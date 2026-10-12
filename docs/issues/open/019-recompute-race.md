# 019 Recompute race in the deferred computation

Phase: bug

## Why
`App.createVisualisation` defers the MDS and clustering by 50 ms (`setTimeout`) so the browser can
repaint, but reads `DataWrapper.sampleList` when the timeout fires. Submitting new data within
those 50 ms makes the first timeout run against the new sample list, with an embedding of `null`
→ `TypeError` in `SampleList.calculateProjectionDistanceMatrix`.

## Tasks
- [ ] Capture the sample list in the closure, or cancel the pending timeout on a new submit
- [ ] Longer term: run the computation in a Web Worker (also keeps the UI responsive for large
  datasets)

## Notes
Only triggered by a script so far, but large datasets make it more likely. Came in with PR #3.

## Done
