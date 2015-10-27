# global define
# global Modernizr

define([
    "Handlebars"
], (
    
) ->
    'use strict'
    numberFormat = (number, options) ->
        numberString = number.toString()
        # split into number and decimal value, if it’s a float
        numberString = numberString.split(".")
        # put dots into number
        numberString[0] = numberString[0].replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1" + ".")
        # join both parts with the wonderful German decimal separator, the comma
        return numberString.join(",")
            
    Handlebars.registerHelper "numberFormat", numberFormat
    return numberFormat
)