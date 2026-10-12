# 018 Sass `@import` → `@use`

Phase: 4 · Current libraries for the visualisations

## Why
Dart Sass 3 will remove `@import` and global functions like `opacify()`. The deprecation
warnings are silenced in `vite.config.js` for now.

## Tasks
- [x] Migrate with `sass-migrator module`, fix what it can’t
- [x] Replace the deprecated colour functions
- [x] Remove `silenceDeprecations` from `vite.config.js`
- [x] Check which Compass stand-in mixins (`styles/compass/_css3.scss`) are still needed;
  most vendor prefixes are obsolete (none were: removed with the whole stand-in, see Done)

## Notes
Might be moot if styles move into Svelte components (015); decide then.

## Done
Partly: commit “Remove the Compass stand-in and unused mixins” replaced the Compass-style mixins
with plain properties and `image-url()` with `url()`, and deleted `compass/` and `_mixins.scss`.
The compiled CSS only lost two `-webkit-` declarations. The `@import`/`@use` migration is still open.

Commit “Use Sass modules (@use) instead of @import”. `sass-migrator module` (2.6.1) first failed because
`$nearColor`/`$farColor`/`$defaultColor` were defined in `main.scss` between the imports (moved
to `_vars.scss`). It then turned the imports after the `html`/`body` rules into
`meta.load-css()`, which `@extend` can't reach across, so `html`/`body` moved into `_base.scss` and
`main.scss` now @uses all partials at the top, in the old order. The only colour function was
`opacify()` → `color.adjust($alpha: …)`. The compiled CSS is identical (rule order included), and the
build shows no deprecation warnings.

