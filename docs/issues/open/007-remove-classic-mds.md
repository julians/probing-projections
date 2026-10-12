# 007 Remove classic MDS and numeric.js

Phase: 0 · Clean up

## Why
`MDS.classic` and `SampleList.calculateMDS` have not been called since at least the first commit
(2015). They are the only reason numeric.js is still a dependency (which also needs a build
warning suppressed in `vite.config.js` because it uses `eval`).

## Tasks
- [ ] Delete `MDS.classic` and `SampleList.calculateMDS`
- [ ] Delete `web/app/scripts/App/data/cities.coffee` (unused test data)
- [ ] Remove `numeric` from `package.json` and the `EVAL` log filter from `vite.config.js`

## Notes
Probably a port of Ben Frederickson’s `mds.js`; `cities.coffee` holds the US city distances from
his demo. It was the in-browser prototype before the projection moved to the Python server.
If classical MDS is wanted again (023), only the top two eigenvectors are needed, which doesn’t
need numeric.js.

## Done
