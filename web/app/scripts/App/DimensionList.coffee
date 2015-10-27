# global define
# global Modernizr
# global Papa

define([
    "Config"
    "Utils"
    "./Sample"
    "./SampleList"
    "./QuantitativeDimension"
    "./BinaryDimension"
    "./MDS"
    "underscore"
    "d3"
], (
    Config
    Utils
    Sample
    SampleList
    QuantitativeDimension
    BinaryDimension
    MDS
    _
    d3
) ->
    'use strict'
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
                unless _.contains(@excludedKeys, key.toLowerCase())
                    if _.isNumber(value)
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
            terms = _.chain(@sampleList.samples)
                .map((sample) ->
                    sample.get(key).split(",")
                )
                .flatten()
                .unique()
                .value()
            
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
            
            
    return DimensionList
)