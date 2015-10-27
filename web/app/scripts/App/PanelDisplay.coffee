# global define
# global Modernizr

define([
    "Config"
    "Utils"
    "./DataWrapper"
    "d3"
    "jquery"
    "underscore"
], (
    Config
    Utils
    DataWrapper
    d3
    $
    _
) ->
    'use strict'
    class PanelDisplay
        constructor: (options) ->
            @$container = $(options.container)
            $heading = @$container.find("h3")
            @selectionKey = @$container.data("selection")
            if @selectionKey
                @$selectionToggle = $("""<span class="selectionToggle"></span>""").appendTo($heading)
                @$selectionToggle.on("click", =>
                    DataWrapper.setActiveSelections(@selectionKey)
                )
                DataWrapper.bind("activeSelections:change", @updateSelectionToggle)
                
                
        updateSelectionToggle: =>
            if @selectionKey
                if @selectionKey == DataWrapper.activeSelections.id
                    @$container.addClass("forActiveSelection")
                else
                    @$container.removeClass("forActiveSelection")

            
    return PanelDisplay
)