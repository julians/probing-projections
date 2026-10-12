import Config from "../Config.coffee"
import Utils from "../Utils.coffee"
import DataWrapper from "./DataWrapper.coffee"
import * as d3 from "d3"
import MicroEvent from "../components/MicroEvent.coffee"

class Heatmap extends MicroEvent
    constructor: (scatterplot) ->
        super()
        @scatterplot = scatterplot
        @container = @scatterplot.svg.select(".heatmapLayer")
        @positions = []
        @dotMargin = 30
        @activeDimension = null
        
        DataWrapper.bind("change:sampleList", @sampleListChange)
    
    
    sampleListChange: () =>
        @dimensionList = DataWrapper.sampleList.dimensionList

        @updateLayout()
        @draw()
    
    
    updateLayout: =>
        @positions = []
        
        if DataWrapper.sampleList?.samples.length
            @dotMargin = Math.round(Math.abs(@scatterplot.x(DataWrapper.sampleList.getMeanDistanceToKClosest(3)) - @scatterplot.x(0)))
            if @dotMargin % 2 > 0 then @dotMargin += 1
            if @dotMargin < 20 then @dotMargin = 20
            if @dotMargin > 40 then @dotMargin = 40
            @numDots = Math.ceil((@scatterplot.x.range()[1] + @scatterplot.margin*2) / @dotMargin)
            offset = @dotMargin/2 + Math.round((@scatterplot.x.range()[1] - Math.ceil(@numDots * @dotMargin)) / 2)
            
            for rowIndex in [0..@numDots]
                for colIndex in [0...@numDots]
                    position = [
                        @scatterplot.x.invert(colIndex * @dotMargin + offset)
                        @scatterplot.y.invert(rowIndex * @dotMargin + offset)
                    ]
                    @positions.push(
                        id: "#{rowIndex}:#{colIndex}"
                        position: position
                        nearest: null
                        valueForDimension: {}
                    )
            
            @populatePoints()
    
                
    populatePoints: =>
        for pos in @positions
            totalDistance = 0
            
            pos.nearest = @knearest(pos.position, 3)
            for item in pos.nearest
                totalDistance += item.distance
            
            for dimension in @dimensionList.dimensions
                totalWeights = 0
                totalValue = 0
                
                for item in pos.nearest
                    weight = totalDistance / item.distance
                    totalWeights += weight
                    totalValue += item.sample.getValueForDimension(dimension) * weight
                
                pos.valueForDimension[dimension.id] = totalValue / totalWeights
    
    
    setActiveDimension: (dimension) =>
        @activeDimension = dimension
        @draw()
    
    
    draw: =>
        #@scatterplot.labelShadowLayer
        #    .style("display", =>
        #        if @activeDimension then return "" else return "none"
        #    )
        
        dots = @container.selectAll(".heatmapDot")
            .data(@positions, (d) -> d.id)
        
        dotsEnter = dots.enter()
            .append("rect")
            .attr("class", "heatmapDot")
            .attr("width", @dotMargin)
            .attr("height", @dotMargin)
            .style("opacity", 0)
            .on("mouseenter", (event, d) =>
                @trigger("mousevalue:change", d)
            )
            
            
        dotsEnter.merge(dots)
            #.transition()
            #    .duration(500)
                .attr("x", (d) =>
                    @scatterplot.x(d.position[0]) - @dotMargin/2
                )
                .attr("y", (d) =>
                    @scatterplot.y(d.position[1]) - @dotMargin/2
                )
                .style("opacity", (d) =>
                    if @activeDimension
                        return d.valueForDimension[@activeDimension.id]
                    if d == @activeDot
                        return 1
                    return 0
                )
                #.style("fill", "black")
                .attr("width", @dotMargin)
                .attr("height", @dotMargin)
            
        dots.exit()
            #.transition()
            #    .duration(500)
            #    .style("opacity", 0)
                .remove()

    
    # the k samples closest to a position, as { sample, distance }
    knearest: (position, k) =>
        nearest = []
        for sample in DataWrapper.sampleList.samples
            distance = Utils.euclideanDistance(position, sample.mdsPosition)
            if nearest.length < k or distance < nearest[nearest.length - 1].distance
                nearest.push(
                    sample: sample
                    distance: distance
                )
                nearest.sort((a, b) -> a.distance - b.distance)
                nearest.pop() if nearest.length > k
        return nearest
        
        
export default Heatmap
