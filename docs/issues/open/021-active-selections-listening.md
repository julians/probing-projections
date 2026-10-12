# 021 `setActiveSelections` never stops listening

Phase: bug

## Why
`DataWrapper.setActiveSelections` tries to stop listening to the previous selection lists with
`for selectionList in @selectionLists`, but `@selectionLists` is an object, and CoffeeScript’s
`for … in` iterates arrays. So it never stops listening, and events from previously active lists
keep being forwarded as `activeSelections:*`.

## Tasks
- [ ] Check what visibly changes when only the active list forwards events
- [ ] Fix with `for key, selectionList of @selectionLists` (or naturally in 014)

## Notes
Present since the first commit; the app may (accidentally) depend on it.

## Done
