# 015 Port the sidebar and tooltips to Svelte

Phase: 3 · Svelte for the UI

## Why
The sidebar panels and tooltips are Handlebars templates plus jQuery DOM code. Porting them
removes jQuery and Handlebars as a side effect.

## Tasks
- [ ] Data entry form (`DataEntry`)
- [ ] Projection settings and panels (`PanelDisplay`)
- [ ] Selection lists for selections, classes and clusters (`SelectionListDisplay`)
- [ ] Dimension list (`DimensionDisplay`)
- [ ] Tooltips (`Tooltip`, `ExplorationTooltip`, the four tooltip templates)
- [ ] Remove jQuery, Handlebars and the `?hbs` Vite plugin

## Notes
jQuery’s `.data()` converts `"5"` to the number `5`, while `element.dataset` stays a string;
the ids from `Utils.uniqueId()` are strings. Check comparisons when replacing `.data()`.

## Done
