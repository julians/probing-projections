import Config from "../Config.coffee"
import Utils from "../Utils.coffee"
import MicroEvent from "../components/MicroEvent.coffee"
import * as d3 from "d3"
import $ from "jquery"
import { difference, uniq } from "es-toolkit"
import Stats from "../Stats.coffee"

class DensityDisplay extends MicroEvent
    constructor: (options) ->
        super()
        @$container = $(options.container)
        
        @baseFillColour = "#999999"
        @baseMarkerColour = Utils.hcl(0, 0, 50)
        
        @subPlotSelections = []
        @subPlots = {}
        @highlightSelection = null
        @highlightPlot = null
        
        @margin =
            top: 3
            bottom: 3
            left: 5
            right: 5
        
        @outerSvg = d3.select(@$container[0]).append('svg')
        @svg = @outerSvg.append("g")
            .attr("transform", "translate(#{@margin.left}, 0)")
            
        @baseLayer = @svg.append("g")
            .attr("class", "baseLayer")
        @subPlotLayer = @svg.append("g")
            .attr("class", "subPlotLayer")
        @quantileLayer = @svg.append("g")
            .attr("class", "quantileLayer")
        @marker = @svg.append("polygon")
            .attr("class", "marker")
        @marker2 = @svg.append("polygon")
            .attr("class", "marker")
        @diffBar = @svg.append("rect")
            .attr("class", "diffBar")
        
        @markerValue = null
        @marker2Value = null
        @markerColour = null
        @marker2Colour = null
        @diffBarValue = null
            
        @x = d3.scaleLinear()
        @y = d3.scaleLinear()
        @diffBarScale = d3.scaleLinear()
            .range([0, 1])
            .domain([0, 1])
        
        @area = d3.area()
            .x((d) => return @x(d[0]))
            .y0(=> return @y(0))
            .y1((d) => return @y(d[1]))

    
    __computeArea: (values, x, y) =>
        area = d3.area()
            .x((d) => return x(d[0]))
            .y0(=> return y(0))
            .y1((d) => return y(d[1]))
        return area(values)
        
        
    __computeLine: (values, x, y) =>
        line = d3.line()
            .x((d) => return x(d[0]))
            .y((d) => return y(d[1]))
        return line(values)
        
        
    __zeroArea: =>
        values = [
            [@x.domain()[0], 0]
            [@x.domain()[1], 0]
        ]
        area = d3.area()
            .x((d) => return @x(d[0]))
            .y0(=> return @y(0))
            .y1((d) => return @y(0))
        return area(values)
    
    
    getOffsetForQuantile: (quantile) =>
        if @baseValues
            value = Stats.quantiles(@baseValues, [quantile])[0]
            width = @x.range()[1] - @x.range()[0]
            return @x(value) - width/2
        else
            return null
    
    
    updateLayout: =>
        @setDimensions()
        @draw()
        
    
    setDimensions: =>
        @width = @$container.width()
        @height = @$container.height()
        
        @outerSvg
            .attr("width", "#{@width}px")
            .attr("height", "#{@height}px")
        
        @x.range([0, @width-@margin.left-@margin.right])
        @y.range([@height-@margin.bottom, @margin.top])
        
        for k, v of @subPlots
            v.y.range([@height-@margin.bottom, 0])
            
        if @highlightPlot
            @highlightPlot.y.range([@height-@margin.bottom, 0])
    
    
    setBasePlotDimension: (dimension) =>
        @dimension = dimension
        @setBasePlotValues(dimension.getAllValues())
    
    
    setBasePlotValues: (values) =>
        @baseValues = values
        @x.domain(d3.extent(@baseValues))
        @basePlot = Stats.kde(@baseValues, d3.range(@x.domain()[0], @x.domain()[1], .1))
        @y.domain([0, d3.max(@basePlot, (d) -> d[1])])
        @quantiles = @dimension.getQuantiles()
        
    
    addPlotForSelection: (selections, draw = true) =>
        unless Array.isArray(selections)
            selections = [selections]
        @subPlotSelections = @subPlotSelections.concat(selections)
        @subPlotSelections = uniq(@subPlotSelections)
        @subPlots = {}
        for selection in @subPlotSelections
            @subPlots[selection.id] = @__computeSubPlotValues(selection)
        if draw then @draw()
        
    
    removePlotForSelection: (selections, draw = true) =>
        unless Array.isArray(selections)
            selections = [selections]
        @subPlotSelections = difference(@subPlotSelections, selections)
        @subPlots = {}
        for selection in @subPlotSelections
            @subPlots[selection.id] = @__computeSubPlotValues(selection)
        if draw then @draw()
    
    
    clearPlots: (draw = true) =>
        @subPlotSelections = []
        @subPlots = {}
        if draw then @draw()
        
    
    __computeSubPlotValues: (selection) =>
        values = selection.getValuesForDimension(@dimension)
        extent = @x.domain()
        plotValues = Stats.kde(values, d3.range(extent[0], extent[1], .1))
        yDomain = d3.scaleLinear()
            .domain([0, d3.max(plotValues, (d) -> d[1])])
            .range([@height-@margin.bottom, 1])
            
        return {
            plotValues: plotValues
            y: yDomain
        }
    
    
    highlightPlotForSelection: (selection, draw = true) =>
        @highlightSelection = selection
        @highlightPlot = null
        if @highlightSelection
            @highlightPlot = @__computeSubPlotValues(selection)
        if draw then @draw()
            
        
    setMarkerValue: (value, draw = true) =>
        @markerValue = value
        if draw then @draw()
        
        
    setMarkerColour: (colour, draw = true) =>
        @markerColour = colour
        if draw then @draw()
        
    
    setMarker2Value: (value, draw = true) =>
        @marker2Value = value
        if draw then @draw()
        
        
    setMarker2Colour: (colour, draw = true) =>
        @marker2Colour = colour
        if draw then @draw()
    
        
    setDiffBarValue: (value, draw = true) =>
        @diffBarValue = value
        if draw then @draw()
    
    
    getDiffBarColour: (l = 60) =>
        h = 0
        c = 0
        if @diffBarValue
            [median] = @dimension.getQuantiles([0.5])
            normalizedMedian = @dimension.normalizeValue(median)
            normalizedValue = @dimension.normalizeValue(@diffBarValue)
            h = 235
            if normalizedMedian > normalizedValue
                h = 10
            c = @diffBarScale(Math.abs(normalizedMedian - normalizedValue))*90
        return Utils.hcl(h, c, l)
    
    
    drawSubPlots: =>
        that = @

        subPlotValues = [].concat(@subPlotSelections)
        if @highlightSelection
            subPlotValues.push(@highlightSelection)
        subPlots = @subPlotLayer.selectAll(".subPlot")
            .data(subPlotValues)
        
        subPlotsEnter = subPlots.enter()
            .append("path")
            .attr("class", "subPlot")
                
        subPlotsEnter.merge(subPlots)
            .attr("d", (d) =>
                if @highlightSelection and @highlightSelection.id == d.id
                    return @__computeArea(@highlightPlot.plotValues, @x, @highlightPlot.y)
                return @__computeArea(@subPlots[d.id].plotValues, @x, @subPlots[d.id].y)
            )
            .style("fill", (d) =>
                return d.colour
            )
            .style("opacity", (d) =>
                if @highlightSelection and @highlightSelection.id == d.id
                    return 1
                return 0.3
            )
            
        subPlots.exit().remove()
        
        subPlotLines = @subPlotLayer.selectAll(".subPlotLine")
            .data(subPlotValues)
        
        subPlotLinesEnter = subPlotLines.enter()
            .append("path")
            .attr("class", "subPlotLine")
                
        subPlotLinesEnter.merge(subPlotLines)
            .attr("d", (d) =>
                if @highlightSelection and @highlightSelection.id == d.id
                    return @__computeLine(@highlightPlot.plotValues, @x, @highlightPlot.y)
                return @__computeLine(@subPlots[d.id].plotValues, @x, @subPlots[d.id].y)
            )
            .style("stroke", (d) =>
                return d.colour
            )
            .style("opacity", (d) =>
                if @highlightSelection
                    if @highlightSelection.id == d.id
                        return 1
                    else
                        return 0.4
                return 0.7
            )
            
        subPlotLines.exit().remove()
    
    
    draw: =>
        basePlot = @baseLayer.selectAll(".basePath")
            .data([@basePlot])
        
        basePlotEnter = basePlot.enter()
            .append("path")
            .attr("class", "basePath")
                
        basePlotEnter.merge(basePlot)
            .attr("d", (d) =>
                return @area(d)
            )
        
        quantileLines = @quantileLayer.selectAll("line")
            .data(@quantiles)
        
        quantileLinesEnter = quantileLines.enter()
            .append("line")
            .attr("class", "quantileLine")
                
        quantileLinesEnter.merge(quantileLines)
            .attr("x1", (d) => @x(d))
            .attr("y1", (d) => @y.range()[0])
            .attr("x2", (d) => @x(d))
            .attr("y2", (d) => @y.range()[1] - @margin.top)
            .classed("median", (d, index) ->
                return index == 1
            )
            
        if @markerValue != null
            @marker
                .style("opacity", 1)
                .attr("points", "0,#{@y(0)+3} 8,#{@y(0)+3} 4,#{@y(0)-3}")
                .attr("transform", "translate(#{(@x.range()[1]-@x.range()[0])*@markerValue-3}, 0)")
                .transition()
                    .duration(100)
                    .style("fill", @markerColour)
        else
            @marker
                .transition()
                    .duration(100)
                    .style("opacity", 0)
                    
        if @marker2Value != null
            @marker2
                .style("opacity", 1)
                .attr("points", "0,#{@y(0)+3} 8,#{@y(0)+3} 4,#{@y(0)-3}")
                .attr("transform", "translate(#{(@x.range()[1]-@x.range()[0])*@marker2Value-3}, 0)")
                .transition()
                    .duration(100)
                    .style("fill", @marker2Colour)
        else
            @marker2
                .transition()
                    .duration(100)
                    .style("opacity", 0)
        
            
        if @diffBarValue != null
            availableHeight = @y.range()[0] - @y.range()[1]
            height = availableHeight * 0.5
            [median] = @dimension.getQuantiles([0.5])
            medianPos = @x(median)
            valuePos = @x(@diffBarValue)
            x = Math.min(medianPos, valuePos)
            width = Math.max(medianPos, valuePos) - Math.min(medianPos, valuePos)
            @diffBar
                .attr("y", (availableHeight-height)/2 + @y.range()[1])
                .attr("height", height)
                .style("fill", @getDiffBarColour)
                #.transition()
                #    .duration(100)
                    .style("opacity", 0.7)
                    .attr("width", width)
                    .attr("x", x)
        else
            @diffBar
                #.transition()
                #    .duration(100)
                    .style("opacity", 0)
            
        @drawSubPlots()
        
        
    transition: (path, d0, d1) =>
        if d0 == d1 then return true
        path.transition()
            .duration(200)
            .attrTween("d", @pathTween(d1, 4))


    pathTween: (d1, precision) ->
        ->
            path0 = this
            path1 = path0.cloneNode()
            n0 = path0.getTotalLength()
            n1 = (path1.setAttribute("d", d1)
            path1
            ).getTotalLength()
            
            # Uniform sampling of distance based on specified precision.
            distances = [0]
            i = 0
            dt = precision / Math.max(n0, n1)
            distances.push i while (i += dt) < 1
            distances.push 1
    
            # Compute point-interpolators at each distance.
            points = distances.map((t) ->
                p0 = path0.getPointAtLength(t * n0)
                p1 = path1.getPointAtLength(t * n1)
                d3.interpolate([p0.x, p0.y], [p1.x, p1.y])
            )
            
            (t) ->
                (if t < 1 then "M" + points.map((p) ->
                    p t
                ).join("L") else d1)

        
export default DensityDisplay
