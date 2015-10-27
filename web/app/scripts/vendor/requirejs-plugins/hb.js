define(['text', 'Handlebars'], function(text, handlebars) {

    var buildCache = {},
        buildCompileTemplate = 'define("{{pluginName}}!{{moduleName}}", ["Handlebars"], function() {return Handlebars.template({{{fn}}})});',
        buildTemplate;

    var load = function(moduleName, parentRequire, load, config) {

        text.get(parentRequire.toUrl(moduleName), function(data) {

            if(config.isBuild) {
                buildCache[moduleName] = data;
                load();
            } else {
                load(Handlebars.compile(data));
            }
        });
    };

    var write = function(pluginName, moduleName, write) {

        if(!handlebars.precompile && require.nodeRequire) {
            try {
                handlebars = require.nodeRequire('Handlebars');
            } catch(error) {
                process.stdout.write("\nLooks like the runtime version of Handlebars is used.\n");
                process.stderr.write("Install handlebars with npm to precompile templates: npm install handlebars --save-dev\n\n");
            }
        }

        if(moduleName in buildCache) {

            if(!buildTemplate) {
                buildTemplate = handlebars.compile(buildCompileTemplate);
            }

            write(buildTemplate({
                pluginName: pluginName,
                moduleName: moduleName,
                fn: handlebars.precompile(buildCache[moduleName])
            }));
        }
    };

    return {
        load: load,
        write: write
    };
});
