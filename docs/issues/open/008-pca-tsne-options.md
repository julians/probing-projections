# 008 Decide on the PCA/t-SNE options

Phase: 0 · Clean up

## Why
`DataEntry.html` has commented-out radio buttons for PCA and t-SNE. The Python server supported
both; the in-browser version (001) only does MDS, and `drType` is now ignored.

## Tasks
- [ ] Decide: remove the commented-out options and `drType`, or implement them
- [ ] If implementing: PCA is small to write; t-SNE needs a library

## Notes
The error displays (stress, distance errors) are designed around MDS; check whether they make
sense for t-SNE before adding it.

## Done
