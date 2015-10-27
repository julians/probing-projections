# global define
# global Modernizr

define([
    "Config"
    "Utils"
    "./DataWrapper"
    "components/MicroEvent"
    "d3"
    "jquery"
    "underscore"
    "science"
], (
    Config
    Utils
    DataWrapper
    sampleList
    d3
    $
    _
    science
) ->
    'use strict'
    class ScatterplotThumbnail
        constructor: (options) ->
            @$container = $(options.container)
            @selection = options.selection or null
            
            @$canvas = $("<canvas></canvas>").appendTo(@$container)
            @canvas = @$canvas[0]
            
            @x = d3.scale.linear()
            @y = d3.scale.linear()

        
        updateLayout: =>
            @setDimensions()
            @draw()
        
        
        setDimensions: =>
            @size = @$container.width()
            
            @$canvas.width(@size)
            @$canvas.height(@size)
            
            @x.range([0, @size])
            @y.range([@size, 0])
        
        
        setSelection: (selection) =>
            @selection = selection
            
        
        draw: =>
            ctx = @canvas.getContext('2d')
            @canvas.width = @size
            @canvas.height = @size
            
            ctx.clearRect(0, 0, @size, @size)
            
            if DataWrapper.sampleList
                @x.domain(DataWrapper.sampleList.mdsExtent.x)
                @y.domain(DataWrapper.sampleList.mdsExtent.y)
                if @selection
                    ctx.fillStyle = @selection.colour.toString()
                    for sample in @selection.getSamples()
                        if sample.mdsPosition
                            ctx.beginPath()
                            ctx.arc(@x(sample.mdsPosition[0]), @y(sample.mdsPosition[1]), 1, 0, Math.PI*2, true)
                            ctx.closePath()
                            ctx.fill()
  
            
    return ScatterplotThumbnail
)