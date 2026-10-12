# 013 Convert CoffeeScript to JavaScript

Phase: 2 · CoffeeScript → JavaScript

## Why
CoffeeScript is effectively dead, and `.svelte` files (014) need JS/TS anyway.

## Tasks
- [ ] Run decaffeinate one module (or a few related ones) per commit, then clean up by hand
- [ ] Keep the app working after each commit (Vite handles mixed `.coffee`/`.js` imports)
- [ ] Remove the CoffeeScript plugin and dependency once nothing is left
- [ ] Optionally: add Prettier and ESLint, decide on TypeScript or JSDoc types

## Notes
CoffeeScript’s `==` compiles to `===`; decaffeinate keeps that, keep an eye on it where values
come from the DOM (see 015).

## Done
