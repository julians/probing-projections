# global define
# global Modernizr

define([
    "jquery"
], (
    $
) ->
    'use strict'
    
    class Tooltip
        template: """<div class="tooltip" role="tooltip"><div class="tooltip-arrow border"></div><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>"""
        autoPositioningOrder: "top bottom left right"
        constructor: (options) ->
            @$container = $(options.container)
            @$tooltip = $(@template)
            @$container.append(@$tooltip)
            @$viewport = options.viewport
            @$viewport = $(@$viewport)
            @$content = @$tooltip.find(".tooltip-inner")
            @$tooltip.addClass("top")
            @followMouse = options.followMouse
            @arrowOffset = 10
            @targetHeight = 0
            @targetWidth = 0
            
        
        onMouseMove: (event) =>
            @setPosition(event.pageX, event.pageY)
        
        
        setContent: (content) =>
            @$content.html(content)
        
            
        show: =>
            @$tooltip.show()
            @$tooltip.addClass("in")
            if @followMouse
                $(document).on("mousemove", @onMouseMove)
            
            
        hide: =>
            @$tooltip.removeClass("in")
                .on("transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd", () =>
                    @$tooltip.hide()
                )
            if @followMouse
                $(document).off("mousemove", @onMouseMove)
        
        
        setTargetDimensions: (height, width) =>
            @targetHeight = height
            @targetWidth = width
            
            
        setPosition: (x, y, order = @autoPositioningOrder) =>
            @choosePositionFromMultiple([{x: x, y: y, order: order}])
        
        
        choosePositionFromMultiple: (positions) =>
            @$tooltip.removeClass("top top-left top-right bottom bottom-left bottom-right left left-top left-bottom right right-top right-bottom")
            finalPosition = null
            finalPositionName = null
            
            for position in positions
                order = position.order or @autoPositioningOrder

                for placement in order.split(" ")
                    if @canBePositionedAt(position.x, position.y, placement)
                        finalPosition = @__calculatePosition(position.x, position.y, placement)
                        finalPositionName = placement
                        break
                if finalPosition
                    break

            if finalPosition.className
                @$tooltip.addClass(finalPosition.className)
            xOffset = 0
            yOffset = 0
            if @targetWidth and @targetHeight
                if finalPositionName == "right"
                    xOffset = @targetWidth/2
                if finalPositionName == "left"
                    xOffset = @targetWidth/-2
                if finalPositionName == "top"
                    yOffset = @targetWidth/-2
                if finalPositionName == "bottom"
                    yOffset = @targetWidth/2
            @$tooltip.css(
                left: "#{finalPosition.x + xOffset}px"
                top: "#{finalPosition.y + yOffset}px"
            )
            
        
        __calculatePosition: (_x, _y, order) =>
            for placement in order.split(" ")
                unless @canBePositionedAt(_x, _y, placement)
                    continue
                
                if placement == "top"
                    hOffset = @__horizontalOffset(_x)
                    return {
                        x: _x + hOffset.x
                        y: _y - @$tooltip.outerHeight() - 10
                        className: "top#{hOffset.className}"
                    }
                else if placement == "bottom"
                    hOffset = @__horizontalOffset(_x)
                    return {
                        x: _x + hOffset.x
                        y: _y
                        className: "bottom#{hOffset.className}"
                    }
                else if placement == "right"
                    vOffset = @__verticalOffset(_y)
                    return {
                        x: _x
                        y: _y + vOffset.y
                        className: "right#{vOffset.className}"
                    }
                else if placement == "left"
                    vOffset = @__verticalOffset(_y)
                    return {
                        x: _x - @$tooltip.outerWidth() - 10
                        y: _y + vOffset.y
                        className: "left#{vOffset.className}"
                    }

        
        __horizontalOffset: (x) =>
            tooltipWidth = @$tooltip.outerWidth()
            rightSpaceLeft = $(window).width() - x
            leftSpaceLeft = $(window).width() - rightSpaceLeft
            xOffset = -(tooltipWidth/2)
            className = ""
            
            if rightSpaceLeft < tooltipWidth/2
                xOffset = -(tooltipWidth - @arrowOffset)
                className = "-left"
            if leftSpaceLeft < tooltipWidth/2
                xOffset = -@arrowOffset
                className = "-right"
                
            return {
                x: xOffset
                className: className
            }
            
            
        __verticalOffset: (y) =>
            tooltipHeight = @$tooltip.outerHeight()
            topSpaceLeft = y - $(window).scrollTop()            
            bottomSpaceLeft = $(window).height() - topSpaceLeft
            yOffset = -(tooltipHeight/2)
            className = ""
            
            if topSpaceLeft < tooltipHeight/2
                yOffset = -@arrowOffset
                className = "-bottom"
            if bottomSpaceLeft < tooltipHeight/2
                yOffset = -(tooltipHeight - @arrowOffset)
                className = "-top"
                
            return {
                y: yOffset
                className: className
            }
        
        
        canBePositionedAt: (x, y, placement) =>
            topSpaceLeft = y - $(window).scrollTop()            
            if placement == "top" and topSpaceLeft >= @$tooltip.outerHeight()
                return true
                
            bottomSpaceLeft = $(window).height() - topSpaceLeft
            if placement == "bottom" and bottomSpaceLeft >= @$tooltip.outerHeight()
                return true
                
            rightSpaceLeft = $(window).width() - x
            if placement == "right" and rightSpaceLeft >= @$tooltip.outerWidth()
                return true
                
            leftSpaceLeft = $(window).width() - rightSpaceLeft
            if placement == "left" and leftSpaceLeft >= @$tooltip.outerWidth()
                return true
        
        
        addClass: (className) =>
            @$tooltip.addClass(className)
            
                    
        removeClass: (className) =>
            @$tooltip.removeClass(className)
            
                    
    return Tooltip
)