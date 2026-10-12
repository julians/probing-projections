import $ from "jquery"
import Handlebars from "handlebars/runtime"

sameFirstWord = (sparte, disziplin, options) ->
    if $.trim(disziplin.split(" ")[0]) == sparte
        options.fn(this)
    else
        options.inverse(this)
        
Handlebars.registerHelper "sameFirstWord", sameFirstWord
export default sameFirstWord
