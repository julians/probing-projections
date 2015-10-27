# global define
# global Modernizr
# global Papa

define([
    "Config"
    "Utils"
    "./DataWrapper"
    "./DensityDisplay"
    "./HeatmapThumbnail"
    "hbs!./templates/DimensionDisplay"
    "components/MicroEvent"
    "jquery"
    "underscore"
], (
    Config
    Utils
    DataWrapper
    DensityDisplay
    HeatmapThumbnail
    DimensionDisplayTemplate
    MicroEvent
    $
    _
) ->
    'use strict'
    class DimensionDisplay extends MicroEvent
        constructor: (options) ->
            @$container = $(options.container)
            @heatmap = options.heatmap
            @heatmap.bind("mousevalue:change", @heatmapMouseMove)
            
            DataWrapper.bind("change:sampleList", @sampleListChange)
            DataWrapper.bind("brushed:selection", @brushedSelection)
            DataWrapper.bind("brushed:sample", @brushedSample)
            DataWrapper.bind("activeSelections:change:active", @activeSelection)
            DataWrapper.bind("activeSelections:change", @activeSelectionChange)
            DataWrapper.bind("plot:mouse:leave", @plotMouseLeave)
            DataWrapper.bind("tempSelection:change", @tempSelectionChange)
            DataWrapper.bind("layoutChange", @updateLayout)
            
            @$container.on("mouseenter mouseleave click", ".actionable", @mouseEvent)
        
        
        mouseEvent: (event) =>
            $el = $(event.currentTarget)
            
            if event.type == "mouseenter"
                type = "over"
            else if event.type == "mouseleave"
                type = "out"
            else
                type = "click"
                if $el.hasClass "active"
                    $el.removeClass "active"
                else
                    @$container.find(".actionable").removeClass("active")
                    $el.addClass("active")
                
            dimension = @dimensionList.getDimensionFromId($el.data("dimension"))
            @trigger("dimension:#{type}", dimension)
        
        
        plotMouseLeave: =>
            @lastHeatmapPoint = null
            for dimensionId, plot of @densityPlots
                plot.setMarkerValue(null)
        
        heatmapMouseMove: (d) =>
            @lastHeatmapPoint = d
            for dimensionId, plot of @densityPlots
                plot.setMarkerValue(d.valueForDimension[dimensionId])
                
                
        brushedSample: (sample) =>
            for dimensionId, plot of @densityPlots
                value = null
                colour = null
                if sample
                    value = sample.getValueForDimension(dimensionId)
                    selectionForSample = DataWrapper.activeSelections.getSelectionForSampleById(sample.id)
                    if selectionForSample
                        colour = selectionForSample.colour
                    else
                        colour = plot.baseMarkerColour
                else if @lastHeatmapPoint
                    value = @lastHeatmapPoint.valueForDimension[dimensionId]
                plot.setMarkerValue(value)
                plot.setMarkerColour(colour)
        
        
        sampleListChange: () =>
            @dimensionList = DataWrapper.sampleList.dimensionList
            @$container.html(@renderContent())
            @createDensityPlots()
            @createHeatmapThumbnails()
            @updateLayout()
        
        
        tempSelectionChange: =>
            selection = DataWrapper.tempSelection
            
            for densityPlot in _.values(@densityPlots)
                densityPlot.removePlotForSelection(selection, false)
                densityPlot.setMarker2Value(null, false)
                densityPlot.setMarker2Colour(null, false)
                
                if selection.samples.length == 1
                    value = selection.samples[0].getValueForDimension(densityPlot.dimension)
                    densityPlot.setMarker2Value(value, false)
                    densityPlot.setMarker2Colour(Config.tempSelectionColour)
                else if selection.samples.length > 1
                    densityPlot.addPlotForSelection(selection, false)
                    
                densityPlot.draw()
                    
        
        brushedSelection: (selection) =>
            for densityPlot in _.values(@densityPlots)
                value = null
                colour = null
                
                if selection?.samples.length == 1
                    value = selection.samples[0].getValueForDimension(densityPlot.dimension)
                    colour = selection.colour
                else
                    densityPlot.highlightPlotForSelection(selection)
                    if @lastHeatmapPoint
                        value = @lastHeatmapPoint.valueForDimension[densityPlot.dimension.id]    

                densityPlot.setMarkerValue(value, false)
                densityPlot.setMarkerColour(colour)
        
        
        activeSelection: (selection) =>
            for densityPlot in _.values(@densityPlots)
                if selection.active
                    densityPlot.addPlotForSelection(selection)
                else
                    densityPlot.removePlotForSelection(selection)
        
        
        activeSelectionChange: =>
            for densityPlot in _.values(@densityPlots)
                densityPlot.clearPlots(false)
                selectionsToAdd = DataWrapper.activeSelections.getActiveSelections()
                densityPlot.addPlotForSelection(selectionsToAdd)
        
        
        updateLayout: =>
            labelMaxWidth = 0
            minMaxWidth = 0
            maxMaxWidth = 0
            
            @$container.find(".dimension").each((index, element) =>
                $el = $(element)
                
                labelWidth = $el.find(".label").width()
                minWidth = $el.find(".range.min").width()
                maxWidth = $el.find(".range.max").width()
                
                if labelWidth > labelMaxWidth then labelMaxWidth = labelWidth
                if minWidth > minMaxWidth then minMaxWidth = minWidth
                if maxWidth > maxMaxWidth then maxMaxWidth = maxWidth
            )
                
            @$container.find(".dimension").each((index, element) =>
                $el = $(element)
                
                $el.find(".label").width(labelMaxWidth)
                $el.find(".range.min").width(minMaxWidth)
                $el.find(".range.max").width(maxMaxWidth)
            )
            
            if @$container.find("ul").length
                window.setTimeout(=>
                    topOffset = @$container.find("ul").offset().top
                    maxHeight = $(window).height() - 20 - topOffset
                    @$container.find("ul").height(maxHeight)
                , 500)
        
        
        createDensityPlots: =>
            @densityPlots = {}
            
            @$container.find(".densityPlot").each((index, element) =>
                $el = $(element)
                dimensionId = $el.data("dimension")
                dimension = @dimensionList.getDimensionFromId(dimensionId)
                
                @densityPlots[dimensionId] = new DensityDisplay(
                    container: element
                )
                @densityPlots[dimensionId].setBasePlotDimension(dimension)
                @densityPlots[dimensionId].updateLayout()
            )
            
        
        createHeatmapThumbnails: =>
            @heatmapThumbnails = {}
            
            @$container.find(".heatmapContainer").each((index, element) =>
                $el = $(element)
                dimensionId = $el.data("dimension")
                dimension = @dimensionList.getDimensionFromId(dimensionId)
                
                @heatmapThumbnails[dimensionId] = new HeatmapThumbnail(
                    container: element
                    heatmap: @heatmap
                )
                @heatmapThumbnails[dimensionId].setDimensionForHeatmap(dimension)
                @heatmapThumbnails[dimensionId].updateLayout()
            )
        
        
        renderContent: (sample) =>
            binaryDimension = []
            quantitativeDimensions = []
            
            if @dimensionList?.dimensions.length
                binaryDimensions = _.chain(@dimensionList.dimensionTree.binary)
                    .map((binaryDimension) ->
                        if binaryDimension.dimensions.length
                            return {
                                label: binaryDimension.label
                                values: _.map(binaryDimension.dimensions, (dimension) ->
                                    return {
                                        term: dimension.term
                                        id: dimension.id
                                    }
                                )
                            }
                        else
                            return null
                    )
                    .compact()
                    .value()
            
                quantitativeDimensions = for quantitativeDimension in @dimensionList.dimensionTree.quantitative
                    value = quantitativeDimension.scale.domain()
                    value = for v in quantitativeDimension.scale.domain()
                        Utils.sigFigs(v, 3)
                    {
                        label: quantitativeDimension.label
                        value: value
                        id: quantitativeDimension.id
                    }
            
            data =
                binaryDimensions: binaryDimensions
                quantitativeDimensions: quantitativeDimensions
                
            return DimensionDisplayTemplate(data)
           
            
    return DimensionDisplay
)