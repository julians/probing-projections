# global define
# global Modernizr
# global Papa

define([
    "Config"
    "Utils"
    "./DataWrapper"
    "underscore"
    "d3"
    "components/MicroEvent"
], (
    Config
    Utils
    DataWrapper
    _
    d3
    MicroEvent
) ->
    'use strict'
    class Heatmap extends MicroEvent
        constructor: (scatterplot) ->
            @scatterplot = scatterplot
            @container = @scatterplot.svg.select(".heatmapLayer")
            @positions = []
            @dotMargin = 30
            @quadtree = null
            @activeDimension = null
            
            DataWrapper.bind("change:sampleList", @sampleListChange)
        
        
        sampleListChange: () =>
            @dimensionList = DataWrapper.sampleList.dimensionList

            @quadtree = d3.geom.quadtree()(for sample in DataWrapper.sampleList.samples
                [sample.mdsPosition[0], sample.mdsPosition[1], sample]
            )
            @quadtree.visit((node, x1, y1, x2, y2) ->
                node.x1 = x1
                node.y1 = y1
                node.x2 = x2
                node.y2 = y2
                return false
            )
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
                
                pos.nearest = for leaf in @knearest(pos.position[0], pos.position[1], 3)
                    distance = Utils.euclideanDistance(pos.position, leaf.point[2].mdsPosition)
                    totalDistance += distance
                    {
                        sample: leaf.point[2]
                        distance: distance
                    }
                
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
                .on("mouseenter", (d) =>
                    @trigger("mousevalue:change", d)
                )
                
                
            dots
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

        
        # calculate mindist between searchpoint and rectangle
        mindist: (x, y, x1, y1, x2, y2) ->
            dx1 = x - x1
            dx2 = x - x2
            dy1 = y - y1
            dy2 = y - y2
            if dx1 * dx2 < 0 # x is between x1 and x2
                # (x,y) is inside the rectangle
                return 0    if dy1 * dy2 < 0 # return 0 as point is in rect
                return Math.min(Math.abs(dy1), Math.abs(dy2))
            # y is between y1 and y2
            # we don't have to test for being inside the rectangle, it's already tested.
            return Math.min(Math.abs(dx1), Math.abs(dx2))    if dy1 * dy2 < 0
            Math.min Math.min(Utils.euclideanDistance([x, y], [x1, y1]), Utils.euclideanDistance([x, y], [x2, y2])), Math.min(Utils.euclideanDistance([x, y], [x1, y2]), Utils.euclideanDistance([x, y], [x2, y1]))
        
        
        knearest: (x, y, k, bestqueue = new Array(@quadtree), resultqueue = [], mindists = {}) =>
            # sort children according to their mindist/dist to searchpoint
            bestqueue.sort (a, b) =>
                # add nodes to minidsts if not there already
                [ a, b ].forEach (val, idx, array) =>
                    unless "id" of val
                        val.id = _.uniqueId()
                    unless val.id of mindists
                        if val.leaf
                            mindists[val.id] = Utils.euclideanDistance([x, y], [val.x, val.y])
                        else
                            mindists[val.id] = @mindist(x, y, val.x1, val.y1, val.x2, val.y2)

                mindists[b.id] - mindists[a.id]
    
            # add nearest leafs if any
            i = bestqueue.length - 1

            while i >= 0
                elem = bestqueue[i]
                if elem.leaf
                    elem.point.selected = true
                    bestqueue.pop()
                    resultqueue.push elem
                else
                    break
                break    if resultqueue.length >= k
                i--
    
            # check if enough points found
            if resultqueue.length >= k or bestqueue.length is 0
                # return if k neighbors found
                return resultqueue
            else
                # add child nodes to bestqueue and recurse
                vistitednode = bestqueue.pop()
        
                # add nodes to queue
                vistitednode.nodes.forEach (val, idx, array) ->
                    bestqueue.push val

        
                # recursion
                @knearest x, y, k, bestqueue, resultqueue, mindists
            
            
    return Heatmap
)