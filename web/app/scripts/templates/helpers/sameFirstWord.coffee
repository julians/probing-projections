# global define
# global Modernizr

define([
    "Handlebars"
], (
    
) ->
    'use strict'
    sameFirstWord = (sparte, disziplin, options) ->
        if $.trim(disziplin.split(" ")[0]) == sparte
            options.fn(this)
        else
            options.inverse(this)
            
    Handlebars.registerHelper "sameFirstWord", sameFirstWord
    return sameFirstWord
)