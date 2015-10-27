# global define
# global Modernizr

define([
    "Config"
    "Utils"
    "./DataWrapper"
    "./DensityDisplay"
    "hbs!./templates/SingleTooltip"
    "hbs!./templates/SampleComparisonTooltip"
    "hbs!./templates/SingleSelectionTooltip"
    "hbs!./templates/MultiSelectionTooltip"
    "components/Tooltip"
    "templates/helpers/ifCond"
    "d3"
    "jquery"
    "components/MicroEvent"
    "underscore"
    "science"
], (
    Config
    Utils
    DataWrapper
    DensityDisplay
    SingleTooltipTemplate
    SampleComparisonTooltipTemplate
    SingleSelectionTooltipTemplate
    MultiSelectionTooltipTemplate
    Tooltip
    ifCondHelper
    d3
    $
    MicroEvent
    _
    science
) ->
    'use strict'
    class ExplorationTooltip extends MicroEvent
        constructor: (options) ->
            @tooltip = new Tooltip(
                container: options.container
            )
            @isMousedOver = false
            @tooltip.$tooltip.on("mouseenter", =>
                @isMousedOver = true
            )
            @tooltip.$tooltip.on("mouseleave", =>
                @isMousedOver = false
                @hide()
            )
            @tooltip.$tooltip.on("click", ".tooltipAction", (event) =>
                $el = $(event.currentTarget)
                action = $el.data("action")
                sample = $el.data("sampleid")
                if sample then sample = DataWrapper.sampleList.getSampleFromId(sample)
                
                @trigger("tooltipAction", {
                    sample: sample
                    action: action
                })
            )

        
        showForContentAtPosition: (options) =>
            @setContent(options.content)
            if options.positions
                @tooltip.choosePositionFromMultiple(options.positions)
            else          
                @setPosition(options.x, options.y)
            @show()
            
        
        setPosition: (x, y) =>
            @tooltip.setPosition(x, y)
            
            
        setContent: (content) =>
            if content.sample
                @setSample(content.sample)
            else if content.samples
                @setSampleComparison(content.samples[0], content.samples[1])
            else if content.selections
                if content.selections.length == 1
                    if content.selections[0].samples.length == 1
                        @setSample(content.selections[0].samples[0], content.selections[0])
                    else
                        @setSelection(content.selections[0])
                else
                    if content.selections.length == 2 and content.selections[0] == content.selections[1]
                        @setSelection(content.selections[0])
                    else
                        @setSelections(content.selections)
                        
        
        show: =>
            @tooltip.show()
            
            
        hide: =>
            unless @isMousedOver
                @tooltip.hide()
        
        
        setSelections: (selections) =>
            dimensionList = DataWrapper.sampleList.dimensionList   
            @tooltip.setContent(@renderMultiSelection(selections))

            @densityPlots = {}
            
            @tooltip.$content.find(".densityPlot").each((index, element) =>
                $el = $(element)
                dimensionId = $el.data("dimension")
                dimension = dimensionList.getDimensionFromId(dimensionId)
            
                @densityPlots[dimensionId] = new DensityDisplay(
                    container: element
                )
                @densityPlots[dimensionId].setBasePlotDimension(dimension)
                @densityPlots[dimensionId].updateLayout()
                for selection in selections
                    if selection.samples.length == 1
                        value = selection.samples[0].getValueForDimension(dimension)
                        @densityPlots[dimensionId].setMarkerValue(value)
                        @densityPlots[dimensionId].setMarkerColour(selection.colour)
                    else
                        @densityPlots[dimensionId].addPlotForSelection(selection)
            )
        
        
        renderMultiSelection: (selections) =>
            maxForDimension = {}
            quantitativeDimensions = for d in DataWrapper.sampleList.dimensionList.dimensionTree.quantitative
                maxForDimension[d.id] = 0
                meanForSelection = []
                for selection in selections
                    mean = science.stats.mean(selection.getValuesForDimension(d))
                    if mean > maxForDimension[d.id]
                        maxForDimension[d.id] = mean
                    meanForSelection.push(
                        value: mean
                        colour: selection.colour
                        highestValue: false
                    )
                    
                {
                    dimension: d
                    meanForSelection: meanForSelection
                }
            
            for d in quantitativeDimensions
                for mean in d.meanForSelection
                    if mean.value == maxForDimension[d.dimension.id]
                        mean.highestValue = true
                    mean.value = parseFloat(mean.value.toPrecision(2))
            
            data =
                selections: selections
                quantitativeDimensions: quantitativeDimensions
                
            tooltipContent = MultiSelectionTooltipTemplate(data)
            
        
        setSelection: (selection) =>
            dimensionList = DataWrapper.sampleList.dimensionList   
            @tooltip.setContent(@renderSingleSelection(selection))

            @densityPlots = {}
            
            @tooltip.$content.find(".densityPlot").each((index, element) =>
                $el = $(element)
                dimensionId = $el.data("dimension")
                dimension = dimensionList.getDimensionFromId(dimensionId)
                
                @densityPlots[dimensionId] = new DensityDisplay(
                    container: element
                )
                @densityPlots[dimensionId].setBasePlotDimension(dimension)
                @densityPlots[dimensionId].updateLayout()
                if selection.samples.length == 1
                    value = selection.samples[0].getValueForDimension(dimension)
                    @densityPlots[dimensionId].setMarkerValue(value)
                    @densityPlots[dimensionId].setMarkerColour(selection.colour)
                else
                    @densityPlots[dimensionId].addPlotForSelection(selection)
            )
        
        
        renderSingleSelection: (selection) =>
            quantitativeDimensions = for d in DataWrapper.sampleList.dimensionList.dimensionTree.quantitative
                mean = science.stats.mean(selection.getValuesForDimension(d))
                zScore = (mean - d.getMean()) / d.getStandardDeviation()
                zScoreRounded = zScore.toPrecision(2)
                if zScore > 0
                    zScoreRounded = "+#{zScoreRounded}"
                else if zScore < 0
                    zScoreRounded = "−#{Math.abs(zScore).toPrecision(2)}"
                {
                    dimension: d
                    mean: parseFloat(mean.toPrecision(2))
                    zScoreForSelection: zScoreRounded
                }
            
            labelCounts = {}
            maxCount = 0
            for sample in selection.samples
                label = sample.getLabel()
                unless labelCounts[label]
                    labelCounts[label] = 0
                labelCounts[label] += 1
                if labelCounts[label] > maxCount then maxCount = labelCounts[label]
                
            labels = for label, count of labelCounts
                {
                    label: label
                    count: count
                }
            labels = _.sortBy(labels, "label")
            if maxCount > 1
                labels = _.sortBy(labels, "count")
            
            data =
                selection: selection
                quantitativeDimensions: quantitativeDimensions
                labels: labels
                
            tooltipContent = SingleSelectionTooltipTemplate(data)
        
        
        setSample: (sample, selection = null) =>
            dimensionList = DataWrapper.sampleList.dimensionList
            @tooltip.setContent(@renderSingleSample(sample, selection))

            @densityPlots = {}
            @densityPlotOffsets = []
            
            @tooltip.$content.find(".densityPlot").each((index, element) =>
                $el = $(element)
                dimensionId = $el.data("dimension")
                dimension = dimensionList.getDimensionFromId(dimensionId)
        
                @densityPlots[dimensionId] = new DensityDisplay(
                    container: element
                )
                @densityPlots[dimensionId].setBasePlotDimension(dimension)
                @densityPlots[dimensionId].updateLayout()
                @densityPlots[dimensionId].setDiffBarValue(sample.get(dimension.key))
                @densityPlotOffsets.push(@densityPlots[dimensionId].getOffsetForQuantile(0.5))
            )
            densityPlotOffsetExtent = d3.extent(@densityPlotOffsets)
            totalOffset = Math.abs(densityPlotOffsetExtent[0]) + Math.abs(densityPlotOffsetExtent[1])
            totalDensityPlotWidth = @tooltip.$content.find(".densityPlot").width()
            totalDensityPlotWidth += totalOffset
            @tooltip.$content.find(".densityPlotContainer").width(Math.ceil(totalDensityPlotWidth))
            
            @tooltip.$content.find(".quantitative").each((index, element) =>
                $el = $(element)
                dimensionId = $el.data("dimension")
                dimension = dimensionList.getDimensionFromId(dimensionId)
                
                $el.find(".densityPlot").css("left", "#{@densityPlotOffsets[index]*-1}px")
                $el.find(".value").css("color", @densityPlots[dimensionId].getDiffBarColour(50).toString())
            )
        
        
        renderSingleSample: (sample, selection = null) =>
            allDimensions = sample.getPrunedDimensionTree()
            
            quantitativeDimensions = for d in allDimensions.quantitative
                value = sample.get(d.key)
                zScore = (value - d.getMean()) / d.getStandardDeviation()
                zScoreRounded = zScore.toPrecision(2)
                if zScore > 0
                    zScoreRounded = "+#{zScoreRounded}"
                else if zScore < 0
                    zScoreRounded = "−#{Math.abs(zScore).toPrecision(2)}"
                {
                    dimension: d
                    valueForSample: Utils.sigFigs(value, 3)
                    zScoreForSample: zScoreRounded
                }
            
            colour = false
            if selection
                colour = selection.colour
            else
                selectionForSample = DataWrapper.activeSelections.getSelectionForSampleById(sample.id)
                if selectionForSample
                    colour = selectionForSample.colour
            
            data =
                sample: sample
                label: sample.getLabel()
                properLabel: sample.hasProperLabel()
                colour: colour
                quantitativeDimensions: quantitativeDimensions
                selection: selection
                displayErrors: DataWrapper.displayErrors
                stress1: parseFloat(sample.getStress1Mean().toPrecision(2))
                totalDistanceError: parseFloat(sample.getTotalDistanceError().toPrecision(2))
                
            tooltipContent = SingleTooltipTemplate(data)
            
          
        setSampleComparison: (sample1, sample2) =>
            dimensionList = DataWrapper.sampleList.dimensionList
            @tooltip.setContent(@renderSampleComparison(sample1, sample2))

            @densityPlots = {}
            @densityPlotOffsets = []
            
            colour1 = false
            if DataWrapper.tempSelection.containsSample(sample1)
                colour1 = DataWrapper.tempSelection.colour
            else
                selectionForSample = DataWrapper.activeSelections.getSelectionForSampleById(sample1.id)
                if selectionForSample
                    colour1 = selectionForSample.colour
                    
            colour2 = false
            if DataWrapper.tempSelection.containsSample(sample2)
                colour2 = DataWrapper.tempSelection.colour
            else
                selectionForSample = DataWrapper.activeSelections.getSelectionForSampleById(sample2.id)
                if selectionForSample
                    colour2 = selectionForSample.colour
            
            @tooltip.$content.find(".densityPlot").each((index, element) =>
                $el = $(element)
                dimensionId = $el.data("dimension")
                dimension = dimensionList.getDimensionFromId(dimensionId)
        
                @densityPlots[dimensionId] = new DensityDisplay(
                    container: element
                )
                @densityPlots[dimensionId].setBasePlotDimension(dimension)
                @densityPlots[dimensionId].updateLayout()
                
                value1 = sample1.getValueForDimension(dimension)
                @densityPlots[dimensionId].setMarkerValue(value1, false)
                @densityPlots[dimensionId].setMarkerColour(colour1, false)
                value2 = sample2.getValueForDimension(dimension)
                @densityPlots[dimensionId].setMarker2Value(value2, false)
                @densityPlots[dimensionId].setMarker2Colour(colour2)
            )
            
            #@tooltip.$content.find(".quantitative").each((index, element) =>
            #    $el = $(element)
            #    dimensionId = $el.data("dimension")
            #    dimension = dimensionList.getDimensionFromId(dimensionId)
            #  
            #    $el.find(".densityPlot").css("left", "#{@densityPlotOffsets[index]*-1}px")
            #    $el.find(".value").css("color", @densityPlots[dimensionId].getDiffBarColour(50).toString())
            #    )
          
            
        renderSampleComparison: (sample1, sample2) =>
            colour1 = false
            if DataWrapper.tempSelection.containsSample(sample1)
                colour1 = DataWrapper.tempSelection.colour
            else
                selectionForSample = DataWrapper.activeSelections.getSelectionForSampleById(sample1.id)
                if selectionForSample
                    colour1 = selectionForSample.colour
                    
            colour2 = false
            if DataWrapper.tempSelection.containsSample(sample2)
                colour2 = DataWrapper.tempSelection.colour
            else
                selectionForSample = DataWrapper.activeSelections.getSelectionForSampleById(sample2.id)
                if selectionForSample
                    colour2 = selectionForSample.colour
            
            allDimensions = sample1.getPrunedDimensionTree()

            quantitativeDimensions = for d in allDimensions.quantitative
                value1 = sample1.get(d.key)
                value2 = sample2.get(d.key)
                console.log colour1.toString(), colour2.toString()
                {
                    dimension: d
                    valueForSample1: parseFloat(value1.toPrecision(2))
                    valueForSample2: parseFloat(value2.toPrecision(2))
                    sample1Highest: value1 > value2
                    sample2Highest: value2 > value1
                    colour1: colour1.toString()
                    colour2: colour2.toString()
                }
            
            data =
                sample1: sample1
                sample2: sample2
                label1: sample1.getLabel()
                label2: sample2.getLabel()
                colour1: colour1
                colour2: colour2
                #binaryDimensions: binaryDimensions
                quantitativeDimensions: quantitativeDimensions
                
            tooltipContent = SampleComparisonTooltipTemplate(data)
  
            
    return ExplorationTooltip
)