# global define
# global Modernizr

define([
    "Config"
    "Handlebars"
], (
    Config
) ->
    "use strict"
    imagePath = () ->
        Config.imagePath
            
    Handlebars.registerHelper "imagePath", imagePath
    return imagePath
)