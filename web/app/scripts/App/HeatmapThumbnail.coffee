import Config from "../Config.coffee"
import Utils from "../Utils.coffee"
import * as d3 from "d3"
import $ from "jquery"

class HeatmapThumbnail
    constructor: (options) ->
        @$container = $(options.container)
        @heatmap = options.heatmap
        
        @$canvas = $("<canvas></canvas>").appendTo(@$container)
        @canvas = @$canvas[0]

    
    updateLayout: =>
        @setDimensions()
        @draw()
    
    
    setDimensions: =>
        @size = @$container.width()
        
        @$canvas.width(@size)
        @$canvas.height(@size)
    
    
    setDimensionForHeatmap: (dimension) =>
        @dimension = dimension
    
    
    draw: =>
        size = Utils.lcm(@size, @heatmap.numDots)
        spacing = size/@heatmap.numDots
        ctx = @canvas.getContext('2d')
        @canvas.width = size
        @canvas.height = size
        ink = d3.rgb(Utils.cssVar("--ink"))
        
        for rowIndex in [0...@heatmap.numDots]
            for colIndex in [0...@heatmap.numDots]
                i = rowIndex * @heatmap.numDots + colIndex
                pos = @heatmap.positions[i]
                
                ctx.fillStyle = "rgba(#{ink.r}, #{ink.g}, #{ink.b}, #{pos.valueForDimension[@dimension.id]})"
                ctx.fillRect(colIndex*spacing, rowIndex*spacing, spacing, spacing)

        
export default HeatmapThumbnail
