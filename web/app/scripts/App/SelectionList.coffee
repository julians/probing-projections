import Config from "../Config.coffee"
import Utils from "../Utils.coffee"
import MicroEvent from "../components/MicroEvent.coffee"
import DataWrapper from "./DataWrapper.coffee"
import Selection from "./Selection.coffee"
import { difference, sortBy } from "es-toolkit"
import * as d3 from "d3"

class SelectionList extends MicroEvent
    constructor: (options) ->
        super()
        @selections = []
        @selectionsById = {}
        @selectionsByLabel = {}
        @broadcastEvents = true
        @id = options?.id or Utils.uniqueId()
        
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
        return Object.keys(@selectionsById)
    
    
    getLabels: =>
        return Object.keys(@selectionsByLabel)
    
    
    getSelectionForSampleById: (id) =>
        for selection in @selections
            sample = selection.getSampleById(id)
            if sample then return selection
        return null
    
    
    getActiveSelections: =>
        return @selections.filter((selection) ->
            return selection.active
        )
    
    
    firstSelection: =>
        return @selections[0]
    
    
    lastSelection: =>
        return @selections[@selections.length-1]
    
    
    add: (selections) =>
        unless Array.isArray(selections)
            selections = [selections]
        @selections = @selections.concat(selections)
        for selection in selections
            @listenTo(selection, "all", (eventName, args...) =>
                if @broadcastEvents
                    @trigger(eventName, args...)
                    @trigger("change")
            )
        
        @updateIndizes()
        @selections = sortBy(@selections, [(selection) ->
            return if selection.temp then 1 else 0
        ])
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
            Object.assign(args, options)
        selection = new Selection(args)
        @add(selection)
        return selection
    
    
    remove: (selections) =>
        unless Array.isArray(selections)
            selections = [selections]
        @selections = difference(@selections, selections)
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
        
        
export default SelectionList
