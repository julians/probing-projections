import Config from "../Config.coffee"
import Utils from "../Utils.coffee"
import * as d3 from "d3"

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
        if prop and prop.split(",").includes(@term)
            return 1*@multiplier
        return 0
        
        
export default BinaryDimension
