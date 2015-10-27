# global define
# global Modernizr

define([
    "Handlebars"
], (
    
) ->
    'use strict'
    multiply = (a, b, options) ->
        a * b
            
    Handlebars.registerHelper "multiply", multiply
    return multiply
)