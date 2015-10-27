# global define
# global Modernizr
# global Papa

define([
    "Config"
    "Utils"
    "components/MicroEvent"
    #"./DataWrapper"
    "underscore"
    "d3"
    "science"
], (
    Config
    Utils
    MicroEvent
    #DataWrapper
    _
    d3
    science
) ->
    'use strict'
    class Selection extends MicroEvent
        constructor: (options) ->
            @samples = []
            @sampleHash = {}
            @id = _.uniqueId()
            @label = options?.label or @id
            @colour = options?.colour or "black"
            @selectionLists = []
            @active = false
            @visible = true
            @hull = null
            
            if options?.samples then @setSamples(options.samples)
        
        
        getSamples: =>
            return @samples
        
        
        containsSample: (sample) =>
            if @sampleHash[sample.id] then return true else return false
        
        
        getSampleById: (id) =>
            return @sampleHash[id]
        
        
        add: (samples) =>
            unless _.isArray(samples)
                samples = [samples]
            for sample in samples
                @sampleHash[sample.id] = sample
            @samples = _.uniq(@samples.concat(samples))
            @hull = null
            @trigger("added", samples)
            @trigger("change")
            
            
        remove: (samples) =>
            unless _.isArray(samples)
                samples = [samples]
            for sample in samples
                delete @sampleHash[sample.id]
            @samples = _.difference(@samples, samples)
            @hull = null
            @trigger("removed", samples)
            @trigger("change")
        
        
        toggle: (samples) =>
            unless _.isArray(samples)
                samples = [samples]
            
            toAdd = []
            toRemove = []
            for sample in samples
                if @sampleHash[sample.id]
                    delete @sampleHash[sample.id]
                    toRemove.push(sample)
                else
                    @sampleHash[sample.id] = sample
                    toAdd.push(sample)
            
            @samples = _.difference(@samples, toRemove)
            @samples = @samples.concat(toAdd)
            @hull = null
            
            if toAdd.length then @trigger("added", toAdd)
            if toRemove.length then @trigger("removed", toRemove)
            @trigger("change")
        
        
        setSamples: (samples) =>
            @samples = samples
            @sampleHash = {}
            for sample in samples
                @sampleHash[sample.id] = sample
            @hull = null
            @trigger("change:samples", @)
            
            
        setLabel: (label) =>
            @label = label
            @trigger("change:label", @)
            
        
        setColour: (colour) =>
            @colour = colour
            @trigger("change:colour", @)
            
            
        getValuesForDimension: (dimension) =>
            values = for sample in @samples
                dimension.valueForSample(sample)
                
            return values
        
        
        setActive: (active) =>
            @active = active
            @trigger("change:active", @)
            
        
        setVisibility: (visibility) =>
            @visible = visibility
            @trigger("change:visibility", @)
            
            
        getHull: =>
            unless @hull
                points = for sample in @samples
                    sample.mdsPosition
                @hull = d3.geom.polygon(d3.geom.hull(points))
            return @hull
            
            
        getCentroid: =>
            if @samples.length == 1
                return @samples[0].mdsPosition
            else if @samples.length == 2
                return Utils.lerp(@samples[0].mdsPosition, @samples[1].mdsPosition, 0.5)
            else
                return @getHull().centroid()
            return null
            
            
    return Selection
)