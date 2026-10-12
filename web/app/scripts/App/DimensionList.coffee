import Config from "../Config.coffee"
import Utils from "../Utils.coffee"
import Sample from "./Sample.coffee"
import SampleList from "./SampleList.coffee"
import QuantitativeDimension from "./QuantitativeDimension.coffee"
import BinaryDimension from "./BinaryDimension.coffee"
import MDS from "./MDS.coffee"
import { uniq } from "es-toolkit"
import d3 from "d3"

class DimensionList
    excludedKeys: [
        "label"
        "class"
        "mds:x"
        "mds:y"
    ]
    constructor: (sampleList) ->
        @sampleList = sampleList
        @dimensions = []
        @dimensionHash = {}
        @dimensionIndex = {}
        @dimensionTree =
            binary: []
            quantitative: []
            
        @createDimensions()
        
        for dimension, index in @dimensions
            @dimensionHash[dimension.id] = dimension
            @dimensionIndex[dimension.id] = index
        
    
    getIndexForDimension: (dimension) =>
        return @dimensionIndex[dimension.id]
    
    
    getDimensionFromId: (id) =>
        return @dimensionHash[id]
    
    
    createDimensions: () =>
        for own key, value of @sampleList.samples[0].data
            unless @excludedKeys.includes(key.toLowerCase())
                if typeof value == "number"
                    @createQuantitativeDimension(key)
                else
                    @createBinaryDimensions(key)
                    
    
    createQuantitativeDimension: (key) =>
        label = key
        domain = false
        weight = false
        modifierSearch = /\[(.*?)\]/
        modifierSearchResult = key.match(modifierSearch)
        if modifierSearchResult
            console.log modifierSearchResult
            label = key.replace(modifierSearchResult[0], "")
            
            for modifierString in modifierSearchResult[1].split(";")
                modifier = modifierString.split(":")[0]
                value = modifierString.split(":")[1]
                
                if modifier == "domain"
                    domain = (parseFloat(v) for v in value.split("-"))
                else if modifier == "weight"
                    weight = parseFloat(value)
            
        dimension = new QuantitativeDimension(
            key: key
            sampleList: @sampleList
            label: label
            multiplier: weight
            domain: domain
        )
        @dimensions.push(dimension)
        @dimensionTree.quantitative.push(dimension)
    
                    
    createBinaryDimensions: (key) =>
        terms = uniq(@sampleList.samples.flatMap((sample) ->
            sample.get(key).split(",")
        ))
        
        multiplier = 1/terms.length
        binaryDimensions = []
        for term in terms
            binaryDimensions.push(new BinaryDimension(
                key: key
                term: term
                multiplier: multiplier
                sampleList: @sampleList
            ))
        
        @dimensionTree.binary.push(
            key: key
            dimensions: binaryDimensions
        )
        @dimensions = @dimensions.concat(binaryDimensions)
        
        
export default DimensionList
