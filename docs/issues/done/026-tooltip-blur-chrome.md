# 026 Tooltip background blur missing in Chrome

Phase: bug

## Why
`.tooltip-inner` sets only `-webkit-backdrop-filter: blur(3px)`, but its `@supports` check also
accepts the unprefixed `backdrop-filter`. In Chrome the check passes and the background drops to
70% opacity, but nothing is blurred, so the plot shows through more than intended. That's more
noticeable in dark mode (025).

## Tasks
- [x] Add the unprefixed `backdrop-filter: blur(3px)`
- [x] Compare the look in Chrome and Safari, light and dark (Chrome only; Safari not available here)

## Notes
Found while doing 025. Not fixed there, so that light mode stayed identical.

## Done
Commit “Blur the tooltip background in all browsers”. The source now has only the unprefixed
property (radius in `--tooltip-blur`); the production build adds `-webkit-backdrop-filter` itself
(Lightning CSS, Vite's default targets include Safari 16). The dev server doesn't prefix. The
`@supports` check keeps both variants, since Lightning CSS doesn't rewrite it. Checked in Chrome
in light and dark mode: the labels behind the tooltip are blurred.

