import Config from "../Config.coffee"
import Utils from "../Utils.coffee"
import DataWrapper from "./DataWrapper.coffee"
import d3 from "d3"
import $ from "jquery"

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

        
export default PanelDisplay
