Interactive MDS Visualisation
=============================

This thing generates an MDS visualisation for you. Just paste your spreadsheet data and go.

How to set up
-------------

You need [node.js](https://nodejs.org) and [pnpm](https://pnpm.io).

1. open `web` directory in Terminal
2. `pnpm install`
3. `pnpm dev`

This serves the app on [localhost:9000](http://localhost:9000/) and recompiles the CoffeeScript, Sass and Handlebars sources whenever they change.

The build is set up with [Vite](https://vite.dev), see `vite.config.js`. Two small plugins in there compile `.coffee` files (CoffeeScript 2) and precompile Handlebars templates imported with `?hbs`, e.g. `import Template from "./templates/App.html?hbs"`.

A few old libraries that only work as global scripts (Modernizr, science.js, Sylvester) live in `app/public/vendor` and are loaded with plain `<script>` tags in `index.html`. d3 v3 gets a small patch (`patches/`) so it works as a module.


### Distributing

`pnpm build` builds the project into `dist/` with relative paths, so it can be uploaded anywhere. `pnpm preview` serves the build locally.
