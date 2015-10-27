# global define
# global Modernizr
# global Papa

define([
    "Config"
    "Utils"
    "underscore"
    "d3"
], (
    Config
    Utils
    _
    d3
) ->
    'use strict'
    class BinaryDimension
        constructor: (options) ->
            @sampleList = options.sampleList
            @key = options.key
            @term = options.term
            @label = options.label or "#{@key}:#{@term}"
            @id = "#{@key}:#{@term}"
            @multiplier = options.multiplier or 1
        
        
        normalizedValueForSample: (sample) =>
            prop = sample.get(@key)
            if prop and _.contains(prop.split(","), @term)
                return 1*@multiplier
            return 0
            
            
    return BinaryDimension
)