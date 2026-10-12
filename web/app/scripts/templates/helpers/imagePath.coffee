import Config from "../../Config.coffee"
import Handlebars from "handlebars/runtime"

imagePath = () ->
    Config.imagePath
        
Handlebars.registerHelper "imagePath", imagePath
export default imagePath
