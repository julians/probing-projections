# 002 Vite and pnpm instead of Grunt, Bower and Compass

Phase: migration

## Why
The Grunt/Bower/Compass toolchain needed a 2014-era Node and Ruby. Nothing installed or built
on a current machine.

## Tasks
- [x] `super()` in constructors of classes extending `MicroEvent` (CoffeeScript 2 needs it)
- [x] RequireJS `define()` → ES `import`/`export default`
- [x] Dependencies from npm via pnpm, Vite config with CoffeeScript and Handlebars plugins
- [x] Remove Gruntfile, bower.json, build.sh, unused vendor scripts
- [x] Update READMEs

## Notes
- The AMD → ESM rewrite was done by a script that pairs dependencies and parameters by position,
  so bindings are unchanged (even odd ones, like `MicroEvent` imported as `sampleList` in
  `ScatterplotThumbnail`).
- d3 v3 needs `this === window` at the top level; fixed with a one-line pnpm patch
  (`web/patches/d3@3.5.17.patch`).
- science.js, Sylvester and Modernizr only work as globals → `web/app/public/vendor`, loaded with
  plain script tags (see 017).
- jQuery 3 exposed a broken delegated click handler in `SelectionListDisplay` (missing callback,
  ignored by jQuery 2); fixed as intended.
- Templates are precompiled with Handlebars 4 via `import Template from "./x.html?hbs"`.

## Done
`19ad597`, `e517dc5`, `c73a0e6`, `5f5c0c9`. Tested in the browser (dev and production build):
sample data, iris (metric/non-metric), clusters, errors, dendrogram, tooltips, selections.
