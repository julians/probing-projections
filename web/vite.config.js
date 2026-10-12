import { defineConfig } from "vite"
import CoffeeScript from "coffeescript"
import Handlebars from "handlebars"
import fs from "node:fs"
import { fileURLToPath } from "node:url"

// Compiles .coffee modules (CoffeeScript 2 outputs ES modules)
function coffee() {
    return {
        name: "coffee",
        transform(code, id) {
            if (!id.endsWith(".coffee")) return null
            const { js, v3SourceMap } = CoffeeScript.compile(code, {
                filename: id,
                bare: true,
                sourceMap: true,
            })
            return { code: js, map: JSON.parse(v3SourceMap) }
        },
    }
}

// `import template from "./foo.html?hbs"` precompiles a Handlebars template
function handlebarsTemplates() {
    return {
        name: "handlebars-templates",
        enforce: "pre",
        load(id) {
            const [file, query] = id.split("?")
            if (query !== "hbs") return null
            this.addWatchFile(file)
            const spec = Handlebars.precompile(fs.readFileSync(file, "utf8"))
            return `import Handlebars from "handlebars/runtime"\nexport default Handlebars.template(${spec})\n`
        },
    }
}

export default defineConfig({
    root: "app",
    base: "./",
    plugins: [coffee(), handlebarsTemplates()],
    build: {
        outDir: "../dist",
        emptyOutDir: true,
        chunkSizeWarningLimit: 1000,
    },
    css: {
        preprocessorOptions: {
            scss: {
                loadPaths: [fileURLToPath(new URL("app/styles", import.meta.url))],
                silenceDeprecations: ["import", "global-builtin", "color-functions"],
            },
        },
    },
    server: {
        port: 9000,
    },
})
