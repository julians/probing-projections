# global define
# global Modernizr
# global Papa

define([
    "Config"
    "Utils"
    "./DataWrapper"
    "underscore"
    "d3"
    "science"
], (
    Config
    Utils
    DataWrapper
    _
    d3
    science
) ->
    'use strict'
    class Sample
        constructor: (data) ->
            @id = _.uniqueId()
            @data = data
            @classSelection = null
            # @dimensionList assigned in SampleList
        
        
        getLabel: =>
            return @data["Label"] or @data["Class"] or @id
            
            
        hasProperLabel: =>
            if @data["Label"] then return true
            return false
        
        
        get: (key) =>
            return @data[key]
            
        
        getClass: =>
            return @classSelection
        
        
        getPrunedDimensionTree: =>
            # removes all binary dimensions that are 0
            dimensionTree =
                binary: []
                quantitative: @dimensionList.dimensionTree.quantitative
            
            for binaryDimension in @dimensionList.dimensionTree.binary
                nonZeroDimensions = []
                for dimension in binaryDimension.dimensions
                    unless dimension.normalizedValueForSample(@) == 0
                        nonZeroDimensions.push(dimension)
                        
                if nonZeroDimensions.length > 0
                    dimensionTree.binary.push(
                        key: binaryDimension.key
                        dimensions: nonZeroDimensions
                    )
            
            return dimensionTree
        
        
        getVector: =>
            for dimension in @dimensionList.dimensions
                dimension.normalizedValueForSample(@)
                
            
        distanceTo: (otherSample) =>
            return DataWrapper.sampleList.getHdDistanceBetweenSamples(@, otherSample)
            
        
        getStress1: (otherSample = null) =>
            if otherSample
                otherIndex = DataWrapper.sampleList.getIndexForSample(otherSample)
                return DataWrapper.sampleList.getStress1ForSample(@)[otherIndex]
                
            return DataWrapper.sampleList.getStress1ForSample(@)
            
            
        getStress1Mean: =>
            return science.stats.mean(DataWrapper.sampleList.getStress1ForSample(@))
        
            
        getValueForDimension: (dimension) =>
            if _.isString(dimension)
                dimension = @dimensionList.getDimensionFromId(dimension)
            return dimension.normalizedValueForSample(@)
            
        
        getAllDistanceErrors: =>
            return DataWrapper.sampleList.getAllDistanceErrorsFromSample(@)
        
            
        getTotalDistanceError: =>
            unless @totalDistanceError
                @totalDistanceError = _.mean(DataWrapper.sampleList.getAllDistanceErrorsFromSample(@))
            return @totalDistanceError
            
        
        getColour: =>    
            if DataWrapper.tempSelection.containsSample(@)
                return DataWrapper.tempSelection.colour
            
            if DataWrapper.brushedSelection and DataWrapper.brushedSelection.containsSample(@)
                return DataWrapper.brushedSelection.colour
        
            selectionForSample = DataWrapper.activeSelections.getSelectionForSampleById(@id)
            if selectionForSample
                return selectionForSample.colour
                
            return Config.baseColour
            
            
    return Sample
)