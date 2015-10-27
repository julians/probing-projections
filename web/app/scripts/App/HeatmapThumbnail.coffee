# global define
# global Modernizr

define([
    "Config"
    "Utils"
    "d3"
    "jquery"
    "underscore"
    "science"
], (
    Config
    Utils
    d3
    $
    _
    science
) ->
    'use strict'
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
            
            for rowIndex in [0...@heatmap.numDots]
                for colIndex in [0...@heatmap.numDots]
                    i = rowIndex * @heatmap.numDots + colIndex
                    pos = @heatmap.positions[i]
                    
                    ctx.fillStyle = "hsla(0, 0%, 0%, #{pos.valueForDimension[@dimension.id]})"
                    ctx.fillRect(colIndex*spacing, rowIndex*spacing, spacing, spacing)
  
            
    return HeatmapThumbnail
)