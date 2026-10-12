import Config from "../Config.coffee"
import Utils from "../Utils.coffee"
import * as d3 from "d3"

class OrdinalDimension
    constructor: (options) ->
        @sampleList = options.sampleList
        @key = options.key
        @label = options.label or "#{@key}"
        @id = @key
        @multiplier = options.multiplier or 1
        @scale = d3.scaleLinear().range([0, @multiplier])
        @normalize()
    
    
    normalizedValueForSample: (sample) =>
        return @scale(@accessor(sample))
        
    
    accessor: (sample) =>
        return sample.get(@key)
    
        
    normalize: =>
        @scale.domain(d3.extent(@sampleList.samples, @accessor))
        
        
export default OrdinalDimension
