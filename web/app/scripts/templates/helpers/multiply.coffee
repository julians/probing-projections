import Handlebars from "handlebars/runtime"

multiply = (a, b, options) ->
    a * b
        
Handlebars.registerHelper "multiply", multiply
export default multiply
