# global define
# global Modernizr

define([
    "hbs/handlebars"
], (
    Handlebars
) ->
    'use strict'
    ifCond = (v1, operator, v2, options) ->
        if operator is "=="
            return if v1==v2 then options.fn(this) else options.inverse(this)

        if operator is "!="
            return if v1!=v2 then options.fn(this) else options.inverse(this)

        if operator is "&&"
            return if v1&&v2 then options.fn(this) else options.inverse(this)

        if operator is "||"
            return if v1||v2 then options.fn(this) else options.inverse(this)

        if operator is "<"
            return if v1<v2 then options.fn(this) else options.inverse(this)

        if operator is "<="
            return if v1<=v2 then options.fn(this) else options.inverse(this)

        if operator is ">"
            return if v1>v2 then options.fn(this) else options.inverse(this)

        if operator is ">="
            return if v1>=v2 then options.fn(this) else options.inverse(this)
            
    Handlebars.registerHelper "ifCond", ifCond
    return ifCond
)