define([
    "underscore"
], (
    _
) ->
    'use strict'

    # underscore addon with sum, mean, median and nrange function
    # see details below
    _.mixin
  
      # Return sum of the elements
      sum: (obj, iterator, context) ->
        return 0  if not iterator and _.isEmpty(obj)
        result = 0
        if not iterator and _.isArray(obj)
          i = obj.length - 1

          while i > -1
            result += obj[i]
            i -= 1
          return result
        each obj, (value, index, list) ->
          computed = (if iterator then iterator.call(context, value, index, list) else value)
          result += computed
          return

        result

  
      # Return aritmethic mean of the elements
      # if an iterator function is given, it is applied before
      mean: (obj, iterator, context) ->
        return Infinity  if not iterator and _.isEmpty(obj)
        return _.sum(obj) / obj.length  if not iterator and _.isArray(obj)
        _.sum(obj, iterator, context) / obj.length  if _.isArray(obj) and not _.isEmpty(obj)

  
      # Return median of the elements 
      # if the object element number is odd the median is the 
      # object in the "middle" of a sorted array
      # in case of an even number, the arithmetic mean of the two elements
      # in the middle (in case of characters or strings: obj[n/2-1] ) is returned.
      # if an iterator function is provided, it is applied before
      median: (obj, iterator, context) ->
        return Infinity  if _.isEmpty(obj)
        tmpObj = []
        if not iterator and _.isArray(obj)
          tmpObj = _.clone(obj)
          tmpObj.sort (f, s) ->
            f - s

        else
          _.isArray(obj) and each(obj, (value, index, list) ->
            tmpObj.push (if iterator then iterator.call(context, value, index, list) else value)
            tmpObj.sort()
            return
          )
        (if tmpObj.length % 2 then tmpObj[Math.floor(tmpObj.length / 2)] else (if (_.isNumber(tmpObj[tmpObj.length / 2 - 1]) and _.isNumber(tmpObj[tmpObj.length / 2])) then (tmpObj[tmpObj.length / 2 - 1] + tmpObj[tmpObj.length / 2]) / 2 else tmpObj[tmpObj.length / 2 - 1]))

  
      # Generate an integer Array containing an arithmetic progression. A port of
      # the native Python `range()` function. See
      # [the Python documentation](http://docs.python.org/library/functions.html#range).
      # replacement of old _.range() faster + incl. convenience operations: 
      #    _.nrange(start, stop) will automatically set step to +1/-1 
      #    _.nrange(+/- stop) will automatically start = 0 and set step to +1/-1
      nrange: (start, stop, step) ->
        if arguments.length <= 1
          return []  if start is 0
          stop = start or 0
          start = 0
        step = arguments[2] or 1 * (start < stop) or -1
        len = Math.max(Math.ceil((stop - start) / step), 0)
        idx = 0
        range = new Array(len)
        loop
          range[idx] = start
          start += step
          break unless (idx += 1) < len
        range
)