# 026 Tooltip background blur missing in Chrome

Phase: bug

## Why
`.tooltip-inner` sets only `-webkit-backdrop-filter: blur(3px)`, but its `@supports` check also
accepts the unprefixed `backdrop-filter`. In Chrome the check passes and the background drops to
70% opacity, but nothing is blurred, so the plot shows through more than intended. That's more
noticeable in dark mode (025).

## Tasks
- [ ] Add the unprefixed `backdrop-filter: blur(3px)`
- [ ] Compare the look in Chrome and Safari, light and dark

## Notes
Found while doing 025. Not fixed there, so that light mode stayed identical.

## Done
