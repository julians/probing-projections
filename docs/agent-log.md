# Agent log

## 2026-10-12 — Project tracking in docs/

- Added [AGENTS.md](../AGENTS.md) (with `CLAUDE.md` importing it), [PLAN.md](PLAN.md), this log
  and one file per issue in `issues/open|done/`.
- Seeded 001–004 as done and 005–023 from the modernisation plan and the loose ends found below.
- Decision: Svelte for the UI (phase 3), with the d3 visualisations wrapped as-is, not rewritten
  declaratively; jQuery goes away with the Svelte port instead of a separate removal.
- Found: `MDS.classic` + `cities.coffee` are an unused 2015 prototype (likely a port of Ben
  Frederickson’s mds.js), the only reason for numeric.js → 007.

## 2026-10-12 — Backbone and Underscore removed

- Own event emitter in `MicroEvent` instead of Backbone.Events ([003](issues/done/003-replace-backbone.md)).
- Underscore → native JS + es-toolkit ([004](issues/done/004-replace-underscore.md)).
- `Object.values(null)` throws where `_.values(null)` didn’t; caught in the browser, guarded.
- Verified by running the previous commit side by side in a worktree on another port; stale DOM
  elements after loading new data turned out to be pre-existing → [022](issues/open/022-stale-elements-after-reload.md).
- Decision: keep jQuery for now (~235 lines, `.data()` type coercion risk), remove with Svelte.

## 2026-10-12 — Vite + pnpm migration

- Merged PR #3 first, then converted RequireJS → ES modules with a script, then Vite/pnpm
  ([001](issues/done/001-merge-pr-3.md), [002](issues/done/002-vite-pnpm.md)). All on the
  `vite` branch, not pushed yet ([005](issues/open/005-merge-vite-branch.md)).
- CoffeeScript 2 classes need `super()` in derived constructors; added before the conversion.
- d3 v3 relies on top-level `this === window`: pnpm patch. science.js/Sylvester/Modernizr only
  work as globals: `public/vendor` script tags.
- Grepping for `$V` missed Sylvester usage (shell escaping); a `no-undef` ESLint pass over the
  compiled CoffeeScript found the remaining implicit globals reliably.
- Browser test gotcha: submitting data right after page load hits a 50 ms race from PR #3
  ([019](issues/open/019-recompute-race.md)); wait for the first render.
