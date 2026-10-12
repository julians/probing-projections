# 003 Own event emitter instead of Backbone

Phase: migration

## Why
Backbone was only used for `Backbone.Events` in `MicroEvent`, and it pulled in Underscore.

## Tasks
- [x] Implement `on`/`bind`, `off`/`unbind`, `trigger` (with Backbone’s `"all"` event),
  `listenTo`, `stopListening` in `web/app/scripts/components/MicroEvent.coffee`
- [x] Remove the `backbone` dependency

## Done
`00635d4`. Emitter tested in Node, app tested in the browser.
