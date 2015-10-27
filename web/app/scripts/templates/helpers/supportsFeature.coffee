# global define
# global Modernizr

define([
    "Handlebars"
], (
    
) ->
    'use strict'
    supportsFeature = (feature, options) ->
        if Modernizr[feature]
            options.fn(this)
        else
            options.inverse(this)
            
    Handlebars.registerHelper "supportsFeature", supportsFeature
    return supportsFeature
)