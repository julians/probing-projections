# global define
# global Modernizr
# global Papa

define([
    "Config"
    "Utils"
    "components/MicroEvent"
    "./DataWrapper"
    "./Selection"
    "underscore"
    "d3"
    "science"
], (
    Config
    Utils
    MicroEvent
    DataWrapper
    Selection
    _
    d3
    science
) ->
    'use strict'
    class SelectionList extends MicroEvent
        constructor: (options) ->
            @selections = []
            @selectionsById = {}
            @selectionsByLabel = {}
            @broadcastEvents = true
            @id = options?.id or _.uniqueId()
            
            if options?.selection then @add(options.selection)
        
        
        turnOffEvents: =>
            @broadcastEvents = false
            
        
        turnOnEvents: =>
            @broadcastEvents = true
        
        
        isEmpty: =>
            return @selections.length == 0
        
        
        getAll: =>
            return @selections
        
        
        getById: (id) =>
            return @selectionsById[id]
        
        
        getByLabel: (label) =>
            return @selectionsByLabel[label]
        
        
        getIds: =>
            return _.keys(@selectionsById)
        
        
        getLabels: =>
            return _.keys(@selectionsByLabel)
        
        
        getSelectionForSampleById: (id) =>
            for selection in @selections
                sample = selection.getSampleById(id)
                if sample then return selection
            return null
        
        
        getActiveSelections: =>
            return _.filter(@selections, (selection) ->
                return selection.active
            )
        
        
        firstSelection: =>
            return @selections[0]
        
        
        lastSelection: =>
            return @selections[@selections.length-1]
        
        
        add: (selections) =>
            unless _.isArray(selections)
                selections = [selections]
            @selections = @selections.concat(selections)
            for selection in selections
                @listenTo(selection, "all", (eventName, args...) =>
                    if @broadcastEvents
                        @trigger(eventName, args...)
                        @trigger("change")
                )
            
            @updateIndizes()
            @selections = _.sortBy(@selections, (selection) ->
                return if selection.temp then 1 else 0
            )
            if @broadcastEvents then @trigger("added", selections)
            if @broadcastEvents then @trigger("change")
        
        
        addNewSelectionWithSamples: (samples, options) =>
            for selection in @selections
                selection.remove(samples)
                
                unless selection.samples.length
                    @remove(selection)
            
            args =
                samples: samples
            if options
                _.extend(args, options)
            selection = new Selection(args)
            @add(selection)
            return selection
        
        
        remove: (selections) =>
            unless _.isArray(selections)
                selections = [selections]
            @selections = _.difference(@selections, selections)
            for selection in selections
                @stopListening(selection)
            
            @updateIndizes()
            if @broadcastEvents then @trigger("removed", selections)
            if @broadcastEvents then @trigger("change")
            
        
        clear: =>
            @selections = []
            @updateIndizes()
            if @broadcastEvents then @trigger("change")
        
        
        autoColour: (offset = 30) =>
            if @selections.length
                colours = Utils.createCategoricalColourScale(@selections.length, offset)
                for colour, index in colours
                    @selections[index].setColour(colour)
        
        
        updateIndizes: =>
            @selectionsById = {}
            @selectionsByLabel = {}
            
            for selection in @selections
                @selectionsById[selection.id] = selection
                @selectionsByLabel[selection.label] = selection
            
            
    return SelectionList
)