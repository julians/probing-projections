# 021 `setActiveSelections` never stops listening

Phase: bug

## Why
`DataWrapper.setActiveSelections` tries to stop listening to the previous selection lists with
`for selectionList in @selectionLists`, but `@selectionLists` is an object, and CoffeeScript’s
`for … in` iterates arrays. So it never stops listening, and events from previously active lists
keep being forwarded as `activeSelections:*`.

## Tasks
- [x] Check what visibly changes when only the active list forwards events
- [x] Fix with `for key, selectionList of @selectionLists` (or naturally in 014)

## Notes
Present since the first commit; the app may (accidentally) depend on it.

## Done
Commit “Forward events only from the active selection list” (stops listening to the previous
active list instead of looping). Worse than described: every switch added another listener, so lists
forwarded events several times. One dependency was found by comparing a 14-step list-switching
scenario with v3: the density plot of a temp selection that was made permanent only went away
through a stale forwarded event. `DimensionDisplay.tempSelectionChange` now removes the previous
temp selection's plot itself. After that, all 14 steps match v3.
