# global define
# global Modernizr
# global Papa

define([
    "Config"
    "Utils"
    "underscore"
    "d3"
    "science"
], (
    Config
    Utils
    _
    d3
    science
) ->
    'use strict'
    class QuantitativeDimension
        constructor: (options) ->
            @sampleList = options.sampleList
            @key = options.key
            @label = options.label or "#{@key}"
            @id = @key
            @quantileMap = {}
            @mean = null
            @stdDeviation = null
            @domain = options.domain or false
            @multiplier = options.multiplier or 1
            @scale = d3.scale.linear().range([0, @multiplier])

            if @domain
                @scale.domain(@domain)
            else
                @normalize()
        
        
        valueForSample: (sample) =>
            @accessor(sample)
        
        
        normalizedValueForSample: (sample) =>
            return @scale(@accessor(sample))
            
        
        normalizeValue: (value) =>
            return @scale(value)
        
        
        accessor: (sample) =>
            return sample.get(@key)
        
            
        normalize: =>
            @scale.domain(d3.extent(@sampleList.samples, @accessor))
            
            
        getAllValues: =>
            unless @rawValues
                @rawValues = _.map(@sampleList.samples, @accessor)
            return @rawValues
            
        
        getMean: =>
            unless @mean
                @mean = science.stats.mean(@getAllValues())
            return @mean
        
            
        getQuantiles: (quantiles = [0.25, 0.5, 0.75]) =>
            returnQuantiles = []
            for quantile in quantiles
                unless @quantileMap[quantile]
                    @quantileMap[quantile] = science.stats.quantiles(@getAllValues(), [quantile])
                returnQuantiles.push(@quantileMap[quantile])
            return returnQuantiles
            
            
        getStandardDeviation: =>
            unless @stdDeviation
                mean = @getMean()
                deviations = for value in @getAllValues()
                    Math.pow(value - mean, 2)
                @stdDeviation = Math.sqrt(science.stats.mean(deviations))
            return @stdDeviation
            
    return QuantitativeDimension
)