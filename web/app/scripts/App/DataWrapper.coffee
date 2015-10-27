# global define
# global Modernizr
# global Papa

define([
    "Config"
    "Utils"
    "./Selection"
    "components/MicroEvent"
    "underscore"
    "d3"
], (
    Config
    Utils
    Selection
    MicroEvent
    _
    d3
) ->
    'use strict'
    class DataWrapper extends MicroEvent
        constructor: () ->
            @sampleList = null
            @activeSelections = null
            @selectionLists = {}
            @brushedSelection = null
            @tempSelection = new Selection(
                colour: Config.tempSelectionColour
                label: "temporary selection"
            )
            
        
        setSampleList: (sampleList) =>
            @sampleList = sampleList
        
        
        getSampleList: =>
            return @sampleList
        
        
        getSelectionList: (key) =>
            return @selectionLists[key] 
            
            
        addSelectionList: (selection, key) =>
            @selectionLists[key] = selection
            
            
        clearAllSelectionLists: (exceptions = null) =>
            for key, selectionList of @selectionLists
                unless exceptions and _.contains(exceptions, key)
                    selectionList.clear()
            @tempSelection.setSamples([])
            
        
        setBrushedSelection: (selection) =>
            @brushedSelection = selection
            @trigger("brushed:selection", selection)
        
        
        addToTemp: (samples) =>
            @tempSelection.add(samples)
            @trigger("tempSelection:change", @tempSelection)
        
            
        removeFromTemp: (samples) =>
            @tempSelection.remove(samples)
            @trigger("tempSelection:change", @tempSelection)
        
            
        setTemp: (samples) =>
            @tempSelection.setSamples(samples)
            @trigger("tempSelection:change", @tempSelection)
        
            
        toggleTemp: (samples) =>
            @tempSelection.toggle(samples)
            @trigger("tempSelection:change", @tempSelection)
        
        
        makeTempPermanent: =>
            numberOfSelections = @selectionLists["user"].selections.length
            @tempSelection.setLabel("Selection #{numberOfSelections+1}")
            
            @createUserSelectionFrom(@tempSelection)
            
            @tempSelection = new Selection(
                colour: Config.tempSelectionColour
            )
            @trigger("tempSelection:change")
        
        
        createUserSelectionFrom: (newSelection) =>
            for selection in @selectionLists["user"].selections
                selection.remove(newSelection.samples)
            @selectionLists["user"].add(newSelection)
            @selectionLists["user"].autoColour(Config.userSelectionColourOffset)
            
            
        removeUserSelection: (selection) =>
            @selectionLists["user"].remove(selection)
            @selectionLists["user"].autoColour(Config.userSelectionColourOffset)
        
            
        setActiveSelections: (key) =>
            if @activeSelections != @selectionLists[key] and @selectionLists[key]
                @activeSelections = @selectionLists[key]

                for selectionList in @selectionLists
                    @stopListening(selectionList)

                @listenTo(@activeSelections, "all", (eventName, args...) =>
                    @trigger("activeSelections:#{eventName}", args...)
                )    
                @trigger("activeSelections:change", key)
            
        
    return new DataWrapper()
)