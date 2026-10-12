# 018 Sass `@import` → `@use`

Phase: 4 · Current libraries for the visualisations

## Why
Dart Sass 3 will remove `@import` and global functions like `opacify()`. The deprecation
warnings are silenced in `vite.config.js` for now.

## Tasks
- [ ] Migrate with `sass-migrator module`, fix what it can’t
- [ ] Replace the deprecated colour functions
- [ ] Remove `silenceDeprecations` from `vite.config.js`
- [x] Check which Compass stand-in mixins (`styles/compass/_css3.scss`) are still needed;
  most vendor prefixes are obsolete (none were: removed with the whole stand-in, see Done)

## Notes
Might be moot if styles move into Svelte components (015); decide then.

## Done
Partly: commit “Remove the Compass stand-in and unused mixins” replaced the Compass-style mixins
with plain properties and `image-url()` with `url()`, and deleted `compass/` and `_mixins.scss`.
The compiled CSS only lost two `-webkit-` declarations. The `@import`/`@use` migration is still open.

