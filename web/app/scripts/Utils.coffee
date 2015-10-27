define([
    "d3"
], (
    d3
) ->
    'use strict'
    
    class Utils
        @transitionEndEvent: "webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend"
        
        @difference: (a, b) ->
            Math.abs(a - b)
        
        
        @sigFigs: (n, sig) ->
            if n == 0 then return 0
            mult = Math.pow(10, sig - Math.floor(Math.log(n) / Math.LN10) - 1)
            Math.round(n * mult) / mult
        
        
        @createCategoricalColourScale: (num, offset = 30, c = 60, l = 60) =>
            delta = 360/num
            return (d3.hcl((h*delta+offset)%360,c,l) for h in [0...num])
        
        
        @gcf: (a, b) =>
            (if (b is 0) then (a) else (@gcf(b, a % b)))
          
          
        @lcm: (a, b) =>
            (a / @gcf(a, b)) * b
          
          
        @euclideanDistance: (a, b) ->
            sumOfSquares = 0
            for v, index in a
                sumOfSquares += Math.pow(v - b[index], 2)
            
            return Math.sqrt(sumOfSquares)
            
        
        @lerp: (from, to, progress) =>
            if _.isArray(from)
                result = for value, index in from
                    value + (to[index] - value) * progress
                return result
            else
                return from + (to - from) * progress
        
            
        @stringifyArray: (a, round = false) ->
            if round
                as = for i in a
                    (Math.round(x, 2) for x in i).join(" ")
            else
                as = (i.join(" ") for i in a)
                    
                
            return as.join("\n")
            
        @fitRectIntoBounds: (rect, bounds) ->
            rectRatio = rect.width / rect.height
            boundsRatio = bounds.width / bounds.height
            newDimensions = {}
    
            # Rect is more landscape than bounds - fit to width
            if rectRatio > boundsRatio
                newDimensions.width = bounds.width
                newDimensions.height = rect.height * (bounds.width / rect.width)
            # Rect is more portrait than bounds - fit to height
            else
                newDimensions.width = rect.width * (bounds.height / rect.height)
                newDimensions.height = bounds.height
                
            newDimensions
        
        
        @haversine: (start, end, options) =>
            # convert to radians
            toRad = (num) ->
                num * Math.PI / 180

            km = 6371
            mile = 3960
            options = options or {}
            R = (if options.unit is "mile" then mile else km)
            dLat = toRad(end.latitude - start.latitude)
            dLon = toRad(end.longitude - start.longitude)
            lat1 = toRad(start.latitude)
            lat2 = toRad(end.latitude)
            a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.sin(dLon / 2) * Math.sin(dLon / 2) * Math.cos(lat1) * Math.cos(lat2)
            c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
            if options.threshold
                options.threshold > (R * c)
            else
                R * c
        
            
        @parseParams: (query) ->
            re = /([^&=]+)=?([^&]*)/g
            decode = (str) ->
                decodeURIComponent(str.replace(/\+/g, ' '))
                
            params = {}
            
            if (query)
                if query.substr(0, 1) == "?"
                    query = query.substr(1)
            
                while e = re.exec(query)
                    k = decode(e[1])
                    v = decode(e[2])
                    if params[k] != undefined
                        if !$.isArray(params[k])
                            params[k] = [params[k]]
                        params[k].push(v)
                    else
                        params[k] = v
                        
            params
        
        
        @preciseRound: (num, decimals) ->
            Math.round(num*Math.pow(10, decimals)) / Math.pow(10, decimals)
        
            
        @cssify: (_string) ->
            _string.replace(/\//g, "").replace(/-/g, "").replace(/\s+/g, "-")
        
            
        @isHighDensity: ->
            (window.matchMedia and (window.matchMedia("only screen and (min-resolution: 124dpi), only screen and (min-resolution: 1.5dppx), only screen and (min-resolution: 48.8dpcm)").matches or window.matchMedia("only screen and (-webkit-min-device-pixel-ratio: 1.5), only screen and (-o-min-device-pixel-ratio: 3/2), only screen and (min--moz-device-pixel-ratio: 1.5), only screen and (min-device-pixel-ratio: 1.5)").matches)) or (window.devicePixelRatio and window.devicePixelRatio > 1.5) 
)