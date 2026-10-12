# Agent log

## 2026-10-12 — “Edit projection” flip regression

- User report: “Edit projection” emptied the panel. `_flip.scss` depended on Modernizr's
  `.csstransforms3d` class, which was removed in [017](issues/done/017-replace-global-vendor-scripts.md).
  The flip is now unconditional.
- Second regression from today's library work that was found by the user, not by me. Neither the
  flip nor making selections permanent was in my comparison scripts. Before removing a library
  that adds global state (classes, globals), grep for *everything* it provides, not just the names
  I expect. [012](issues/open/012-e2e-smoke-test.md) should click through every control once.

## 2026-10-12 — Bugs 019–022, d3 duplicate-key regression

- User report: selections could no longer be made permanent or renamed. A regression from d3 v7:
  v3 dropped data with duplicate keys, v7 enters it. Fixed with `uniqBy` before the two affected joins.
- 021 fixed; the app relied on it in one place (density plot of a made-permanent temp selection).
- 019 short-term fix (cancel + capture + no drawing without positions); Web Worker still open.
- 022 was mostly the hidden-pane rAF artefact plus aborted draws, and one real bug (`transitionend`
  never fires in a hidden list). 020 was dead code.
- Verified with scripted scenarios against a v3 worktree (`web-old`) with a temporary rAF shim in both.
- Lesson: my 016 probe only covered the paths I thought of. Making selections permanent and switching
  lists were missing. The Playwright smoke test ([012](issues/open/012-e2e-smoke-test.md)) should cover them.

## 2026-10-12 — kNN benchmark, quantiles as numbers

- Benchmarked the old quadtree k-nearest search against the new loop (table in [016](issues/done/016-d3-v7.md)):
  the old search was inexact from ~1000 samples on, and the loop is faster up to ~5000.
- Voronoi layer: never enabled anywhere in the history, probably a predecessor of `Heatmap`.
- [024](issues/done/024-quantiles-as-arrays.md): quantiles are now numbers. Also fixed a 0-valued cache
  miss and renamed `mean` → `median`. A before/after digest via `git stash` was identical.
- For small before/after checks, `git stash` in the same tab is enough; a worktree isn't needed.

## 2026-10-12 — d3 v7, global vendor scripts removed

- d3 v3 → v7 ([016](issues/done/016-d3-v7.md)), then science.js/Sylvester/Modernizr → own code
  ([017](issues/done/017-replace-global-vendor-scripts.md)). Two commits; no global scripts are left.
- Verified against a worktree of the previous commit (`web-old`, port 9011) with scripted interactions
  and DOM digests. Only intentional differences remain (path rounding).
- Silent v3→v7 traps that the comparison caught: cardinal tension (0.7 in v3 = 0.1 in v7) and HCL
  colours (new Lab constants, up to ~60/255 shift) → `Utils.hcl` keeps v3's conversion.
- Decision: port science.js 1:1 instead of d3-array (null handling, array-returning quantiles → [024](issues/open/024-quantiles-as-arrays.md)).
- Removed dead code: the Voronoi heatmap layer (never enabled) and the `supportsFeature` helper.
- Testing gotcha: in the hidden browser pane, `requestAnimationFrame` stalls, so d3 transitions never
  run and exit transitions leave elements behind. That looked like a regression. Fix: take a
  screenshot first, or temporarily shim rAF with `setTimeout` in both versions under test.
- Testing gotcha: after `pnpm add`, restart the dev server, otherwise Vite serves the old prebundled dependency.

## 2026-10-12 — Classical MDS / PCA, SMACOF start

- `MDS.classical` replaces the numeric.js version: Jacobi eigen solver on the smaller of the
  scatter and Gram matrices ([007](issues/done/007-remove-classic-mds.md)).
- Classical MDS equals PCA here (euclidean distances on the normalised vectors; checked to 1e-14),
  so the UI offers one “Classical MDS / PCA” option ([008](issues/open/008-pca-tsne-options.md)).
- The first version ran Jacobi on the n×n matrix and took 4 s at n=500. Switching to the d×d
  scatter matrix made it about 1 ms.
- SMACOF now starts from classical MDS: same stress (±0.5%), 20–60× faster than 10 random starts
  ([023](issues/done/023-smacof-classical-init.md)).
- Fixed in passing: Recompute did nothing on data with `mds:x`/`mds:y` columns.
- t-SNE was researched, not built. The blocker is the error displays, not the computation (notes in 008).
- Port 9000 was taken by another session, so `.claude/launch.json` (untracked) got a `web-alt` config on 9010.

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
