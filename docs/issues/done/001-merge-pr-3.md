# 001 Projection and clustering in the browser (PR #3)

Phase: migration

## Why
The projection and clustering used to run on a Flask/scikit-learn server (Heroku), which no
longer exists. PR #3 by Marian Dörk ports both to CoffeeScript so the app works as static files.

## Tasks
- [x] Merge PR #3 (SMACOF MDS in `MDS.coffee`, Ward clustering in `HierarchicalCluster.coffee`,
  Compass stand-in in `styles/compass/_css3.scss`)

## Notes
Merged locally *before* the RequireJS → ES module conversion. That conversion dedents every
file, so merging the PR afterwards would have conflicted on almost every line it touches.
The PR’s `build.sh` and `bower.json` were later replaced by the Vite setup (002).

## Done
`866fb42` (merge commit on the `vite` branch).
