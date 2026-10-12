# 022 Old dots and clusters stay in the DOM after loading new data

Phase: bug

## Why
After loading the sample data (36 samples) and then iris (150), the scatterplot has 186
`circle.dot` elements, and the cluster list contains the old clusters next to the new ones
(with opacity 0). Same behaviour before and after 002–004.

## Tasks
- [x] Check whether it’s visible or affects interaction (hover, brushing on invisible dots?)
- [x] Probably missing `exit().remove()` calls or stale selections; fix, or let 014/016 fix it

## Notes
Observed 2026-10-12 while testing 004.

## Done
Three causes:
- Mostly a test artefact: in the hidden browser pane `requestAnimationFrame` stalls, so exit
  transitions never end. With working animations, loading new data leaves no dots behind.
- The `TypeError` from 019/021 aborted a draw halfway, which did leave dots and list items.
- Real bug: removed selection list items waited for `transitionend`, which never fires while the
  list is hidden (the class list after loading data without classes). They stayed invisible in the
  DOM and joined the next data join. Fixed in “Remove fading selection list items reliably”.
