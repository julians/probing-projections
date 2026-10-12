# 009 Check the Typekit fonts

Phase: 0 · Clean up

## Why
`index.html` loads Adelle Sans through a Typekit kit (`flq8uqg`) with the old async loader
snippet. It worked on localhost on 2026-10-12, but the kit is tied to an Adobe account and its
domain list, and the app silently falls back to `sans-serif` if it stops working.

## Tasks
- [ ] Check the kit in the Adobe Fonts account: still active, allowed for the deployment domain?
- [ ] Replace the loader snippet with the current `<link rel="stylesheet" href="https://use.typekit.net/…css">`
- [ ] Optionally: decide whether to keep Adobe Fonts or switch to a self-hosted font

## Notes

## Done
