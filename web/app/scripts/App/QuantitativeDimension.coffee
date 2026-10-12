import Config from "../Config.coffee"
import Utils from "../Utils.coffee"
import * as d3 from "d3"
import Stats from "../Stats.coffee"

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
        @scale = d3.scaleLinear().range([0, @multiplier])

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
            @rawValues = @sampleList.samples.map(@accessor)
        return @rawValues
        
    
    getMean: =>
        unless @mean
            @mean = Stats.mean(@getAllValues())
        return @mean
    
        
    getQuantiles: (quantiles = [0.25, 0.5, 0.75]) =>
        returnQuantiles = []
        for quantile in quantiles
            unless quantile of @quantileMap
                @quantileMap[quantile] = Stats.quantiles(@getAllValues(), [quantile])[0]
            returnQuantiles.push(@quantileMap[quantile])
        return returnQuantiles
        
        
    getStandardDeviation: =>
        unless @stdDeviation
            mean = @getMean()
            deviations = for value in @getAllValues()
                Math.pow(value - mean, 2)
            @stdDeviation = Math.sqrt(Stats.mean(deviations))
        return @stdDeviation
        
export default QuantitativeDimension
