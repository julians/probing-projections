import Handlebars from "handlebars/runtime"

supportsFeature = (feature, options) ->
    if Modernizr[feature]
        options.fn(this)
    else
        options.inverse(this)
        
Handlebars.registerHelper "supportsFeature", supportsFeature
export default supportsFeature
