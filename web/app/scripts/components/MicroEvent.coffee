define([
    "backbone"
], (
    Backbone
) ->
    class MicroEvent
        
    _.extend(MicroEvent::, Backbone.Events)
        #bind: (events, fct) ->
        #    @_events = @_events or {}
        #    for e in events.split(" ")
        #        @_events[e] = @_events[e] or []
        #        @_events[e].push fct
        #    return
        #  
        #unbind: (events, fct) ->
        #    @_events = @_events or {}
        #    for e in events.split(" ")
        #        continue if e of @_events is false
        #        @_events[e].splice @_events[e].indexOf(fct), 1
        #    return
        #  
        #trigger: (event) -> # , args...
        #    @_events = @_events or {}
        #    return  if event of @_events is false
        #    i = 0
        #    
        #    while i < @_events[event].length
        #        @_events[event][i].apply this, Array::slice.call(arguments, 1)
        #        i++
        #    return
            
    return MicroEvent
)