import Config from "../Config.coffee"
import Utils from "../Utils.coffee"
import DataWrapper from "./DataWrapper.coffee"
import MDS from "./MDS.coffee"
import Heatmap from "./Heatmap.coffee"
import MicroEvent from "../components/MicroEvent.coffee"
import * as d3 from "d3"
import $ from "jquery"
import { uniqBy } from "es-toolkit"

class Scatterplot extends MicroEvent
    constructor: (options) ->
        super()
        @$container = $(options.container)
        
        @transitionDuration = 250
        
        @showDendrogram = false
        @displayErrors = false
        @displayLabels = true
        @visualVariables =
            size: null
            haloSize: null
        @visualVariableDefaults = 
            size: [3.5, 3.5]
            haloSize: [3.5, 3.5]
        @visualScales =
            size: d3.scaleSqrt().domain([0, 1]).range(@visualVariableDefaults.size)
            haloSize: d3.scaleSqrt().domain([0, 1]).range(@visualVariableDefaults.haloSize)
        @maxHaloRadius = 20
        
        @clusterLineMaxWidth = 4
        
        @margin = 10
        
        @$container.html("""
            <svg>
                <defs>
                    <filter id="blurFilter" x="-50%" y="-50%" width="200%" height="200%">
                        <feGaussianBlur in="SourceGraphic" stdDeviation="2" />
                    </filter>
                  </defs>
            </svg>
        """)
        @outerSvg = d3.select(@$container.find("svg")[0])
            .attr('class', 'chart')
            .on("mousedown", @mouseDownListener)
            .on("mousemove", @mouseMoveListener)
            .on("mouseup", @mouseUpListener)
            .on("mouseenter", (event, d) =>
                @trigger("mouse:enter", d)
                DataWrapper.trigger("plot:mouse:enter")
            )
            .on("mouseleave", (event, d) =>
                @trigger("mouse:leave", d)
                DataWrapper.trigger("plot:mouse:leave")
            )

        @svg = @outerSvg.append('g')
            .attr("transform", "translate(#{@margin}, #{@margin})")
            .on("click", @clickOffListener)
        
        #@labelShadowLayer = @svg.append("g")
        #    .attr("class", "labelShadowLayer")
        #    .style("display", "none")
        
        @heatmapLayer = @svg.append("g")
            .attr("class", "heatmapLayer")
        
        @hullLayer = @svg.append("g")
            .attr("class", "hullLayer")
                
        @clusterLineLayer = @svg.append("g")
            .attr("class", "clusterLineLayer")
        
        @haloLayer = @svg.append("g")
            .attr("class", "haloLayer")
        
        @lineLayer = @svg.append("g")
            .attr("class", "lineLayer")
            
        @labelLayer = @svg.append("g")
            .attr("class", "labelLayer")
            
        @dotLayer = @svg.append("g")
            .attr("class", "dotLayer")
            
        @brushLayer = @svg.append("g")
            .attr("class", "brushLayer")
            
        @x = d3.scaleLinear()
        @y = d3.scaleLinear()
        
        @updateLayout()
        
        DataWrapper.bind("change:sampleList", @sampleListChange)
        DataWrapper.bind("brushed:selection", @draw)
        DataWrapper.bind("tempSelection:change", @draw)
        DataWrapper.bind("activeSelections:change", @draw)
    
    
    mouseDownListener: (event) =>
        p = d3.pointer(event, @svg.node())
        @brushing =
            pos: p
            shiftKey: event.shiftKey
        @brushLayer.append("rect")
            .attr("class", "selectionRect")
            .attr("x", p[0])
            .attr("y", p[1])
            .attr("width", 0)
            .attr("height", 0)
    
    
    mouseMoveListener: (event) =>
        if @brushing
            p = d3.pointer(event, @svg.node())

            move = 
                x: p[0] - @brushing.pos[0],
                y: p[1] - @brushing.pos[1]
                
            attrs =
                width: Math.abs(move.x)
                height: Math.abs(move.y)
                
            if move.x < 0
                attrs.x = p[0]
            else
                attrs.x = @brushing.pos[0]
            if move.y < 0
                attrs.y = p[1]
            else
                attrs.y = @brushing.pos[1]
                
            rect = @brushLayer.select(".selectionRect")
            for name, value of attrs
                rect.attr(name, value)
    
    
    mouseUpListener: (event) =>
        if @brushing
            @brushLayer.select(".selectionRect").remove()
            
            p = d3.pointer(event, @svg.node())
            move = 
                x: p[0] - @brushing.pos[0],
                y: p[1] - @brushing.pos[1]
            
            selectionRect = {}
            
            if move.x < 0
                selectionRect.x1 = p[0]
                selectionRect.x2 = @brushing.pos[0]
            else
                selectionRect.x1 = @brushing.pos[0]
                selectionRect.x2 = p[0]
            if move.y < 0
                selectionRect.y1 = p[1]
                selectionRect.y2 = @brushing.pos[1]
            else
                selectionRect.y1 = @brushing.pos[1]
                selectionRect.y2 = p[1]

            selectedSamples = DataWrapper.sampleList.samples.filter((sample) =>
                x = @x(sample.mdsPosition[0])
                y = @y(sample.mdsPosition[1])
                
                return x >= selectionRect.x1 and
                x <= selectionRect.x2 and
                y >= selectionRect.y1 and
                y <= selectionRect.y2
            )
             
            @trigger("selection", {
                samples: selectedSamples
                shiftKey: @brushing.shiftKey
            })
                    
            @brushing = false
    
    
    clickOffListener: =>
        @activeNode = null
        console.log "clickoff"
        @draw()
        @trigger("click:off")
    
    
    updateLayout: =>
        dimension = Math.min(@$container.width(), @$container.height())

        @outerSvg
            .attr("width", "#{dimension}px")
            .attr("height", "#{dimension}px")
        @svg
            .attr("transform", "translate(#{@margin}, #{@margin})")
        
        @x.range([0, dimension - @margin*2])
        @y.range([dimension - @margin*2, 0])
        
    
    setVisualScales: =>
        if @visualVariables.size
            @visualScales.size.range([1, @visualVariableDefaults.size[0]*3])
        else
            @visualScales.size.range(@visualVariableDefaults.size)
            
        if @visualVariables.haloSize
            @visualScales.haloSize.range([1, @visualVariableDefaults.haloSize[0]])
        else
            @visualScales.haloSize.range(@visualVariableDefaults.haloSize)
    
    
    sampleListChange: () =>
        @x.domain(DataWrapper.sampleList.mdsExtent.x)
        @y.domain(DataWrapper.sampleList.mdsExtent.y)
        
        # reset active/hovered nodes
        @activeNode = null
        @hoveredNode = null

        @draw()
    
    
    setDendrogramVisibility: (visibility) =>
        @showDendrogram = visibility
        @draw()
    
    
    setErrorDisplayVisibility: (visibility) =>
        @displayErrors = visibility
        @draw()
    
    
    setLabelVisibility: (visibility) =>
        @displayLabels = visibility
        @draw()
    
    
    showPositionsRelativeTo: (sample) =>
        @activeNode = sample
        @draw()
        
        
    togglePositionsRelativeTo: (sample) =>
        if @activeNode == sample
            @activeNode = null
        else
            @activeNode = sample
        @draw()
    
    
    draw: =>
        that = @
        relativePositions = {}
        activeNodePosition = null
        hoveredNodePosition = null
        
        sampleList = DataWrapper.sampleList
        # the samples of new data have no positions until the projection
        # has been computed (see issue 019)
        unless sampleList and sampleList.samples.every((sample) -> sample.mdsPosition)
            return false
        
        if @hoveredNode or @activeNode
            relativePositions = @calculatePositionsRelativeTo(@activeNode or @hoveredNode)            
            if @activeNode
                activeNodePosition = [
                    @x(@activeNode.mdsPosition[0])
                    @y(@activeNode.mdsPosition[1])
                ]
            if @hoveredNode
                hoveredNodePosition = [
                    @x(@hoveredNode.mdsPosition[0])
                    @y(@hoveredNode.mdsPosition[1])
                ]
        
        @setVisualScales()


        # hulls
        
        hullLineGenerator = d3.line()
            .x((d) =>
                @x(d[0])
            )
            .y((d) =>
                @y(d[1])
            )
            # the curve of d3 v3’s "cardinal-closed" with its default tension
            # of 0.7; d3 v4+ scales the tangents by (1 - tension) / 6
            # instead of / 2, so the equivalent tension is 0.1
            .curve(d3.curveCardinalClosed.tension(0.1))
        
        hullSelections = []
        unless @activeNode
            for selection in DataWrapper.activeSelections.selections
                if selection.active
                    hullSelections.push(selection)
            if DataWrapper.brushedSelection
                hullSelections.push(DataWrapper.brushedSelection)
            # the brushed selection can also be an active one; d3 v3
            # dropped such duplicate keys, v4+ would draw the hull twice
            hullSelections = uniqBy(hullSelections, (d) -> d.id)
            
        hulls = @hullLayer.selectAll(".hull")
            .data(hullSelections.filter((d) -> d.samples.length > 2), (d) -> d.id)
        
        hullsEnter = hulls.enter()
            .append("path")
            .attr("class", "hull")
            .style("opacity", 0)
            .style("fill", (d) -> d.colour)
            .attr("d", (d) ->
                return hullLineGenerator(d.getHull())
            )
            
        hullsEnter.merge(hulls)
            .attr("d", (d) ->
                return hullLineGenerator(d.getHull())
            )
            .transition()
                .duration(50)
                .style("opacity", (d) ->
                    if DataWrapper.brushedSelection and d == DataWrapper.brushedSelection
                        return 0.2
                    return 0.1
                )
                .style("fill", (d) -> d.colour)
                
        hulls.exit()
            .transition()
                .duration(150)
                .style("opacity", 0)
                .remove()
                
        
        hullLines = @hullLayer.selectAll(".hullLine")
            .data(hullSelections.filter((d) -> d.samples.length == 2), (d) -> d.id)
        
        hullLinesEnter = hullLines.enter()
            .append("line")
            .attr("class", "hullLine")
            .style("opacity", 0)
            .style("stroke", (d) -> d.colour)
            .attr("x1", (d) =>
                return @x(d.samples[0].mdsPosition[0])
            )
            .attr("y1", (d) =>
                return @y(d.samples[0].mdsPosition[1])
            )
            .attr("x2", (d) =>
                return @x(d.samples[1].mdsPosition[0])
            )
            .attr("y2", (d) =>
                return @y(d.samples[1].mdsPosition[1])
            )
            
        hullLinesEnter.merge(hullLines)
            .attr("x1", (d) =>
                return @x(d.samples[0].mdsPosition[0])
            )
            .attr("y1", (d) =>
                return @y(d.samples[0].mdsPosition[1])
            )
            .attr("x2", (d) =>
                return @x(d.samples[1].mdsPosition[0])
            )
            .attr("y2", (d) =>
                return @y(d.samples[1].mdsPosition[1])
            )
            .transition()
                .duration(50)
                .style("opacity", (d) ->
                    if DataWrapper.brushedSelection and d == DataWrapper.brushedSelection
                        return 0.2
                    return 0.1
                )
                .style("stroke", (d) -> d.colour)
                
        hullLines.exit()
            .transition()
                .duration(150)
                .style("opacity", 0)
                .remove()
            
        
        
        # dendrogram
        
        if @showDendrogram
            clusterData = sampleList.hierarchicalClustering?.getClustering() or null
            clusterLineData = clusterData?.clusterLines or []
            clusterLineScale = d3.scaleLinear().domain([0, 0]).range([0, 0])
        else
            clusterLineData = []
        
        if clusterLineData.length
            clusterLineScale
                .domain(clusterData.levelExtent)
                .range([0.5, 0.05])
                
        clusterLines = @clusterLineLayer.selectAll(".clusterLine")
            .data(clusterLineData)
        
        clusterLinesEnter = clusterLines.enter()
            .append("line")
            .attr("class", "clusterLine")
            .attr("x1", (d) =>
                return @x(d.pjPositions[0][0])
            )
            .attr("y1", (d) =>
                return @y(d.pjPositions[0][1])
            )
            .attr("x2", (d) =>
                return @x(d.pjPositions[1][0])
            )
            .attr("y2", (d) =>
                return @y(d.pjPositions[1][1])
            )
            .style("opacity", 0)
            
        clusterLinesEnter.merge(clusterLines)
        .transition()
            .duration(@transitionDuration)
            .attr("x1", (d) =>
                return @x(d.pjPositions[0][0])
            )
            .attr("y1", (d) =>
                return @y(d.pjPositions[0][1])
            )
            .attr("x2", (d) =>
                return @x(d.pjPositions[1][0])
            )
            .attr("y2", (d) =>
                return @y(d.pjPositions[1][1])
            )
            .style("opacity", (d) =>
                return if @activeNode then 0 else 1
            )
            .style("stroke-width", (d) =>
                lineWidth = @clusterLineMaxWidth/d.level*2
                if lineWidth < 0.5 then lineWidth = 0.5
                return "#{lineWidth}px"
            )
            
        clusterLines.exit()
            .transition()
                .duration(@transitionDuration)
                .attr("x1", (d) =>
                    return @x(d.pjPositions[0][0])
                )
                .attr("y1", (d) =>
                    return @y(d.pjPositions[0][1])
                )
                .attr("x2", (d) =>
                    return @x(d.pjPositions[1][0])
                )
                .attr("y2", (d) =>
                    return @y(d.pjPositions[1][1])
                )
                .style("opacity", 0)
                .on("end", (d) ->
                    d3.select(this).remove()
                )
        
        
        
        
        # halos
        
        haloData = []
        if @displayErrors or (@hoveredNode and not @activeNode)
            haloData = sampleList.samples
        #else
        #    haloData = 
            
        halos = @haloLayer.selectAll(".halo")
            .data(haloData, (d) -> d.id)
        
        halosEnter = halos.enter()
            .append("circle")
            .attr("class", "halo")
            .attr("r", @visualVariableDefaults.haloSize[0])
            .style("opacity", 0)
            #.attr("filter", "url(#blurFilter)")
              
        halosEnter.merge(halos)
            .attr("class", (d) =>
                className = "halo"
                if @hoveredNode and d.id != @hoveredNode.id
                    className = @addDistanceDeltaToClass(className, relativePositions[d.id].distanceDelta)
                else if not @activeNode and not @hoveredNode
                    className = @addDistanceDeltaToClass(className, d.getTotalDistanceError())
                return className
            )
            .transition()
                .duration(@transitionDuration)
                .attr("r", (d) =>
                    value = @visualVariableDefaults.haloSize[0]
                    
                    if @activeNode
                        return 0
                    else if @hoveredNode
                        if relativePositions[d.id].distanceDelta
                            value += Math.sqrt(Math.abs(d.getStress1(@hoveredNode) * 50))
                            if value > @maxHaloRadius
                                value = @maxHaloRadius
                    else
                        value += Math.sqrt(Math.abs(d.getStress1Mean() * 50))
                        if value > @maxHaloRadius
                            value = @maxHaloRadius
                    return value
                )
                .attr("cx", (d, index) =>
                    if @activeNode and d != @activeNode.id
                        return @x(relativePositions[d.id].pos[0])
                    return @x(d.mdsPosition[0])
                )
                .attr("cy", (d, index) =>
                    if @activeNode and d != @activeNode.id
                        return @y(relativePositions[d.id].pos[1])
                    return @y(d.mdsPosition[1])
                )
                .style("opacity", (d) =>
                    if (@hoveredNode and d.id == @hoveredNode.id) or (@activeNode and d.id == @activeNode.id)
                        return 0
                    return 1
                )
            
        halos.exit()
            .transition()
                .duration(@transitionDuration)
                .style("opacity", 0)
                .remove()
        
        
        # lines
        
        lines = @lineLayer.selectAll(".line")
            .data(Object.keys(if @activeNode then relativePositions else {}), (d) -> d)
            
        linesEnter = lines.enter()
            .append("line")
            .attr("class", "line")
            .attr("x1", (d) =>
                return @x(sampleList.getSampleFromId(d).mdsPosition[0])
            )
            .attr("y1", (d) =>
                return @y(sampleList.getSampleFromId(d).mdsPosition[1])
            )
            .attr("x2", (d) =>
                return @x(sampleList.getSampleFromId(d).mdsPosition[0])
            )
            .attr("y2", (d) =>
                return @y(sampleList.getSampleFromId(d).mdsPosition[1])
            )
            .style("opacity", 0)
            
        linesEnter.merge(lines)
            .attr("class", (d) =>
                className = "line"
                if d != @activeNode?.id# and d!= @hoveredNode?.id
                    className = @addDistanceDeltaToClass(className, relativePositions[d].distanceDelta)
                return className
            )
            .transition()
            .duration(@transitionDuration)
            .attr("x1", (d) =>
                return @x(sampleList.getSampleFromId(d).mdsPosition[0])
            )
            .attr("y1", (d) =>
                return @y(sampleList.getSampleFromId(d).mdsPosition[1])
            )
            .attr("x2", (d) =>
                if @activeNode then return @x(relativePositions[d].pos[0])
                
                x = @x(sampleList.getSampleFromId(d).mdsPosition[0])
                y = @y(sampleList.getSampleFromId(d).mdsPosition[1])
                dist = 7
                if relativePositions[d].distanceDelta > 0 then dist *= -1
                return @moveVectorTowardsOtherVector([x, y], hoveredNodePosition, dist)[0]
            )
            .attr("y2", (d) =>
                if @activeNode then return @y(relativePositions[d].pos[1])
                
                x = @x(sampleList.getSampleFromId(d).mdsPosition[0])
                y = @y(sampleList.getSampleFromId(d).mdsPosition[1])
                dist = 7
                if relativePositions[d].distanceDelta > 0 then dist *= -1
                return @moveVectorTowardsOtherVector([x, y], hoveredNodePosition, dist)[1]
            )
            .style("opacity", (d) =>
                if @activeNode and @activeNode.id == d then return 0
                return 0.7
            )
            .style("stroke", (d) =>
                if @activeNode
                    if relativePositions[d].distanceDelta < 0 then return "hsl(0, 0%, 100%)"
                    return "hsl(180, 0%, 82%)"
                return ""
            )
            
        lines.exit()
            .transition()
                .duration(@transitionDuration)
                .attr("x1", (d) =>
                    sample = sampleList.getSampleFromId(d)
                    if sample
                        return @x(sample.mdsPosition[0])
                    return null
                )
                .attr("y1", (d) =>
                    sample = sampleList.getSampleFromId(d)
                    if sample
                        return @y(sample.mdsPosition[1])
                    return null
                )
                .attr("x2", (d) =>
                    sample = sampleList.getSampleFromId(d)
                    if sample
                        return @x(sample.mdsPosition[0])
                    return null
                )
                .attr("y2", (d) =>
                    sample = sampleList.getSampleFromId(d)
                    if sample
                        return @y(sample.mdsPosition[1])
                    return null
                )
                .style("opacity", 0)
                .on("end", (d) ->
                    d3.select(this).remove()
                )
        
        
        # dots
            
        dots = @dotLayer.selectAll(".dot")
            .data(sampleList.samples, (d) -> d.id)
        
        dotsEnter = dots.enter()
            .append("circle")
            .attr("class", "dot")
            .attr("r", 5.5)
            .style("opacity", 0)
            .on("click", (event, d) =>
                @trigger("selection", {
                    samples: [d]
                    shiftKey: event.shiftKey
                })
                #if d == that.activeNode
                #    that.activeNode = null
                #else
                #    that.activeNode = d
                #
                #that.draw()    
                #that.trigger("dot:clicked", {
                #    sample: d
                #    boundingRect: this.getBoundingClientRect()
                #})
            )
            
        unless Utils.isTouchDevice
            dotsEnter
                .on("mouseover", (event, d) ->
                    that.hoveredNode = d
                    that.draw()
                    
                    that.trigger("dot:over", {
                        sample: d
                        boundingRect: this.getBoundingClientRect()
                    })
                    DataWrapper.trigger("brushed:sample", d)
                )
                .on("mouseout", (event, d) ->
                    that.hoveredNode = null
                    that.draw()
                    
                    that.trigger("dot:out", {
                        sample: d
                        boundingRect: this.getBoundingClientRect()
                    })
                    DataWrapper.trigger("brushed:sample", null)
                )
              
        dotsEnter.merge(dots)
            .attr("class", (d) =>
                className = "dot"
                if @activeNode or @hoveredNode
                    if d == @activeNode then className += " selected"
                    if d == @hoveredNode then className += " hovered"
                    className = @addDistanceDeltaToClass(className, relativePositions[d.id].distanceDelta)
                return className
            )
            .transition()
                .duration(@transitionDuration)
                .attr("r", (d) =>
                    value = 1
                    if @visualVariables.size
                        value = d.getValueForDimension(@visualVariables.size)
                        value /= @visualVariables.size.multiplier
                    return @visualScales.size(value)
                )
                .attr("cx", (d, index) =>
                    if @activeNode and d != @activeNode
                        @x(relativePositions[d.id].pos[0])
                    else
                        @x(d.mdsPosition[0])
                )
                .attr("cy", (d, index) =>
                    if @activeNode and d != @activeNode
                        @y(relativePositions[d.id].pos[1])
                    else
                        @y(d.mdsPosition[1])
                )
                .style("opacity", 1)
                .style("fill", @getFillStyleForSample)
            
        dots.exit()
            .transition()
                .duration(@transitionDuration)
                .style("opacity", 0)
                .remove()
        
        labelList = []        
        if @displayLabels
            labelList = sampleList.samples
        #@drawLabels(@labelShadowLayer, labelList, relativePositions)
        @drawLabels(@labelLayer, labelList, relativePositions)
        
    
    drawLabels: (layer, labelList, relativePositions) =>
        that = @
        
        labels = layer.selectAll(".dotLabel")
            .data(labelList, (d) -> d.id)
        
        labelsEnter = labels.enter()
            .append("text")
            .attr("class", "dotLabel")
            .style("opacity", 0)
            .text((d) ->
                d.getLabel()
            )
            .on("click", (event, d) =>
                @trigger("selection", {
                    samples: [d]
                    shiftKey: event.shiftKey
                })
            )
        
        unless Utils.isTouchDevice
            labelsEnter
                .on("mouseover", (event, d) =>
                    that.hoveredNode = d
                    that.draw()
                    
                    point = @dotLayer.selectAll(".dot")
                        .filter((pd) -> pd.id == d.id)

                    that.trigger("dot:over", {
                        sample: d
                        boundingRect: point.node().getBoundingClientRect()
                    })
                    DataWrapper.trigger("brushed:sample", d)
                )
                .on("mouseout", (event, d) =>
                    that.hoveredNode = null
                    that.draw()
                    
                    point = @dotLayer.selectAll(".dot")
                        .filter((pd) -> pd.id == d.id)
                    
                    that.trigger("dot:out", {
                        sample: d
                        boundingRect: point.node().getBoundingClientRect()
                    })
                    DataWrapper.trigger("brushed:sample", null)
                )
        
        labelsEnter.merge(labels).transition()
            .duration(@transitionDuration)
            .attr("x", (d, index) =>
                value = 1
                if @visualVariables.size
                    value = d.getValueForDimension(@visualVariables.size)
                    value /= @visualVariables.size.multiplier
                offset = @visualScales.size(value) + 3
                
                if @activeNode and d != @activeNode
                    return @x(relativePositions[d.id].pos[0]) + offset
                else
                    return @x(d.mdsPosition[0]) + offset
            )
            .attr("y", (d, index) =>
                if @activeNode and d != @activeNode
                    return @y(relativePositions[d.id].pos[1]) + 5
                else
                    return @y(d.mdsPosition[1]) + 5
            )
            .style("opacity", 1)
            .style("fill", @getFillStyleForSample)
        
        labels.exit()
            .transition()
                .duration(@transitionDuration)
                .style("opacity", 0)
                .remove()
    
    
    getFillStyleForSample: (d) =>
        if DataWrapper.tempSelection.containsSample(d)
            return DataWrapper.tempSelection.colour
            
        if DataWrapper.brushedSelection and DataWrapper.brushedSelection.containsSample(d)
            return DataWrapper.brushedSelection.colour
        
        selectionForSample = DataWrapper.activeSelections.getSelectionForSampleById(d.id)
        if selectionForSample
            if DataWrapper.brushedSelection or DataWrapper.tempSelection.samples.length
                return Utils.hcl(selectionForSample.colour.h, selectionForSample.colour.c * 0.25, selectionForSample.colour.l)
            else
                return selectionForSample.colour
        
        return Config.baseColour
    
    
    highlightSelection: (selection) =>
        @highlightedSelection = selection
        @draw()
    
    
    addDistanceDeltaToClass: (className, distanceDelta = 0) =>
        if distanceDelta < 0
            className += " nearer"
        if distanceDelta > 0
            className += " farther"
        return className
    
        
    calculatePositionsRelativeTo: (baseSample) =>
        calculatedDistances = DataWrapper.sampleList.getAllHdDistancesFromSample(baseSample)
        
        mdsDistances = DataWrapper.sampleList.getAllProjectionDistancesFromSample(baseSample)
        
        # min/max distances, ignoring 0 values
        distanceScale = d3.scaleLinear()
            .domain(d3.extent(calculatedDistances, (d) -> return (if d == 0 then null else d)))
            .range(d3.extent(mdsDistances, (d) -> return (if d == 0 then null else d)))
        
        relativePositions = {}
        for sample, index in DataWrapper.sampleList.samples
            correctedDistance = distanceScale(sample.distanceTo(baseSample))
            #correctedDistance = sample.distanceTo(baseSample)
            samplePos = @moveVectorTowardsOtherVector(baseSample.mdsPosition, sample.mdsPosition, correctedDistance)

            relativePositions[sample.id] =
                distanceDelta: 1 - mdsDistances[index]/correctedDistance
                pos: samplePos
                
        return relativePositions
        
    
    # moves from by dist in the direction of to (stays at from if both
    # are the same point)
    moveVectorTowardsOtherVector: (from, to, dist) =>
        dx = to[0] - from[0]
        dy = to[1] - from[1]
        length = Math.sqrt(dx * dx + dy * dy)
        if length == 0
            return [from[0], from[1]]
        return [
            from[0] + dx / length * dist
            from[1] + dy / length * dist
        ]
    
    
    setVisual: (variable, dimension) =>
        @visualVariables[variable] = dimension
        @draw()

        
    getVisual: (variable) =>
        return @visualVariables[variable]
        
        
export default Scatterplot
