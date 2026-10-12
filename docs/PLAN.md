# Modernisation plan

Goal: a codebase that is pleasant to work on again, without breaking the visualisation. Each phase
should leave the app working; verify in the browser after every step.

## Done so far

- [x] [001](issues/done/001-merge-pr-3.md) Projection and clustering in the browser (PR #3)
- [x] [002](issues/done/002-vite-pnpm.md) Vite and pnpm instead of Grunt, Bower and Compass
- [x] [003](issues/done/003-replace-backbone.md) Own event emitter instead of Backbone
- [x] [004](issues/done/004-replace-underscore.md) es-toolkit and native JS instead of Underscore

## Phase 0: Clean up

Get rid of dead code and loose ends before touching anything big.

- [ ] [005](issues/open/005-merge-vite-branch.md) Merge the `vite` branch and push
- [ ] [006](issues/open/006-remove-python-backend.md) Remove the Python backend
- [x] [007](issues/done/007-remove-classic-mds.md) Remove classic MDS and numeric.js
- [ ] [008](issues/open/008-pca-tsne-options.md) Decide on the PCA/t-SNE options (PCA done, t-SNE open)
- [ ] [009](issues/open/009-typekit-fonts.md) Check the Typekit fonts
- [ ] [010](issues/open/010-readme-fork-wording.md) Fix the Readme’s fork wording

## Phase 1: Safety net

Every later phase rewrites a lot of code, and there are no tests yet.

- [ ] [011](issues/open/011-unit-tests.md) Unit tests for the computation (Vitest)
- [ ] [012](issues/open/012-e2e-smoke-test.md) End-to-end smoke test of the main flow (Playwright)

## Phase 2: CoffeeScript → JavaScript

- [ ] [013](issues/open/013-coffeescript-to-js.md) Convert module by module

## Phase 3: Svelte for the UI

Svelte replaces the hand-written wiring (Handlebars templates rendered with jQuery, a global event
bus). The d3 visualisations stay imperative, wrapped in components.

- [ ] [014](issues/open/014-svelte-shell-and-state.md) App shell and a reactive state module
- [ ] [015](issues/open/015-svelte-sidebar-ui.md) Port the sidebar and tooltips (removes jQuery and Handlebars)

## Phase 4: Current libraries for the visualisations

- [x] [016](issues/done/016-d3-v7.md) d3 v3 → v7
- [x] [017](issues/done/017-replace-global-vendor-scripts.md) Replace science.js, Sylvester and Modernizr
- [x] [018](issues/done/018-sass-use.md) Sass `@import` → `@use`

## Bugs and ideas (any time)

- [ ] [019](issues/open/019-recompute-race.md) Recompute race in the deferred computation (short-term fix done, Web Worker open)
- [x] [020](issues/done/020-class-display-template.md) `ClassDisplayTemplate` is undefined
- [x] [021](issues/done/021-active-selections-listening.md) `setActiveSelections` never stops listening
- [x] [022](issues/done/022-stale-elements-after-reload.md) Old dots and clusters stay in the DOM after loading new data
- [x] [023](issues/done/023-smacof-classical-init.md) Idea: start SMACOF from classical MDS
- [x] [024](issues/done/024-quantiles-as-arrays.md) Quantiles are one-element arrays
- [x] [025](issues/done/025-custom-properties-dark-mode.md) More custom properties, rough dark mode
- [x] [026](issues/done/026-tooltip-blur-chrome.md) Tooltip background blur missing in Chrome
