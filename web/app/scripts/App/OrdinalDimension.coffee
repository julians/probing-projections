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
    class OrdinalDimension
        constructor: (options) ->
            @sampleList = options.sampleList
            @key = options.key
            @label = options.label or "#{@key}"
            @id = @key
            @multiplier = options.multiplier or 1
            @scale = d3.scale.linear().range([0, @multiplier])
            @normalize()
        
        
        normalizedValueForSample: (sample) =>
            return @scale(@accessor(sample))
            
        
        accessor: (sample) =>
            return sample.get(@key)
        
            
        normalize: =>
            @scale.domain(d3.extent(@sampleList.samples, @accessor))
            
            
    return OrdinalDimension
)