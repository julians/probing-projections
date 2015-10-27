# global define
# global Modernizr

define([
    "Handlebars"
], (
    
) ->
    'use strict'
    forEach = (arr, options) ->
        return options.inverse(this) if options.inverse and not arr.length
        
        arr.map((item, index) ->
            item = new String(item) if typeof item is "string"
            item.$index = index
            item.$first = index is 0
            item.$last = index is arr.length - 1
            options.fn item
        ).join ""
            
    Handlebars.registerHelper "forEach", forEach
    return forEach
)