# 014 Svelte app shell and reactive state

Phase: 3 · Svelte for the UI

## Why
UI state is synchronised by hand: a global `DataWrapper` singleton, about 50 `bind`/`trigger`
calls through `MicroEvent`, and Handlebars templates re-rendered with jQuery. Svelte’s reactive
state replaces most of that.

## Tasks
- [ ] Add Svelte 5 to the Vite setup, mount an `App.svelte` shell with the existing layout
- [ ] Replace `DataWrapper` with a state module (a class in a `.svelte.js` file using `$state`)
- [ ] Wrap the d3 visualisations (`Scatterplot`, `Heatmap`, density plots) in components via
  `bind:this`/actions, driven by state instead of events
- [ ] Remove `MicroEvent` once nothing triggers events any more

## Notes
Don’t rewrite the visualisations declaratively in this step; `Scatterplot` alone is ~950 lines of
d3 with brushing, Voronoi, hulls and transitions.

## Done
