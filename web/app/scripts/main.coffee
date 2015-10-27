require.config(
    
    paths:
        d3: '../bower_components/d3/d3'
        jquery: '../bower_components/jquery/dist/jquery'
        jqueryTap: "vendor/jquery.tap"
        underscore: '../bower_components/underscore/underscore'
        underscoreMath: 'vendor/underscore.math'
        Handlebars: "../bower_components/handlebars/handlebars"
        text: "vendor/requirejs-plugins/text"
        hb: "vendor/requirejs-plugins/hb"
        hbs: '../bower_components/require-handlebars-plugin/hbs'
        json: "../bower_components/requirejs-plugins/src/json"
        victor: "../bower_components/build/victor"
        science: "vendor/science"
        backbone: "vendor/backbone"
    
    hbs:
        helpers: false,            # default: true
        #i18n: false,              # default: false
        templateExtension: 'html', # default: 'hbs'
        #partialsUrl: ''           # default: ''
        
    shim:
        underscore:
            exports: '_'
        #Handlebars:
        #    exports: "Handlebars"
        jqueryTap:
            deps: ["jquery"]
        d3:
            exports: "d3"
        science:
            exports: "science"
            deps: ["d3"]
)



require([
    "App/App"
], (
    App
) ->
    "use strict"
    
    $ ->
        app = new App(
            container: "#vizzyviz"
        )
)
