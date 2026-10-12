# The subset of Backbone.Events this project uses: on/bind, off/unbind,
# trigger (including Backbone's catch-all "all" event), listenTo and
# stopListening
class MicroEvent
    on: (events, callback, context) ->
        @_events ?= {}
        for name in events.split(/\s+/)
            (@_events[name] ?= []).push(
                callback: callback
                context: context ? @
            )
        return @


    off: (events, callback) ->
        return @ unless @_events
        names = if events then events.split(/\s+/) else Object.keys(@_events)
        for name in names when @_events[name]
            @_events[name] = (handler for handler in @_events[name] when callback? and handler.callback != callback)
        return @


    trigger: (name, args...) ->
        return @ unless @_events
        for handler in (@_events[name] or []).slice()
            handler.callback.apply(handler.context, args)
        for handler in (@_events.all or []).slice()
            handler.callback.apply(handler.context, [name, args...])
        return @


    listenTo: (other, events, callback) ->
        other.on(events, callback, @)
        (@_listeningTo ?= []).push(
            other: other
            callback: callback
        )
        return @


    stopListening: (other) ->
        for listening in (@_listeningTo or []) when not other? or listening.other == other
            listening.other.off(null, listening.callback)
        @_listeningTo = (listening for listening in (@_listeningTo or []) when other? and listening.other != other)
        return @


MicroEvent::bind = MicroEvent::on
MicroEvent::unbind = MicroEvent::off


export default MicroEvent
