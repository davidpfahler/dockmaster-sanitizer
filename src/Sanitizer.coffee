"use strict"
_ = require 'lodash'
{Transform} = require 'stream'

class Sanitizer extends Transform
  _chunks: ''

  _transform: (chunk, encoding, callback) ->
    @_chunks += chunk.toString 'utf8'
    callback()

  _flush: (callback) ->
    @push JSON.stringify @_sanitize @_chunks
    @_chunks = ''
    callback()

  unwrap = (data) ->
    keys = _.keys(data)
    if _.isObject(data) and not _.isArray data
      if keys.length is 1
        return unwrap data[_.keys(data)?[0]]
      else
        _.each keys, (key) ->
          if _.isObject(data[key]) or _.isArray(data[key])
            data[key] = unwrap data[key]
        return data
    else if _.isArray data
      result = []
      _.each data, (item) ->
        result.push unwrap item
      return result
    else
      return new Error 'unable to unwrap data object'

  _sanitize: (data) ->
    # capture erros returned form the DockMaster API
    regex = /\{"Message":"(.+)"\}/
    if capture = data.match regex
      return new Error capture[1]

    # capture responses sent when content-type was not x-www-form-urlencoded
    regex = /<string xmlns="DBWC">(\{".+"\})<\/string>/
    if capture = data.match regex
      data = capture[1]
      # the rest of the procedure can take it from here

    try
      data = JSON.parse data
    catch e
      console.error e
      console.log "initial response: #{data}"
      return new Error "unable to parse initial response: "

    # We begin to untangle the mess that is returned by the API
    data = data.d if data.d
    # If the response is empty, it will look something like '{"workorders":}'.
    # In that case, we need to return an empty object or array.
    debugger
    if capture = data.match /^\{"([a-zA-Z]+)":\}$/
      return switch capture[1]
        when "workorders" then []
        else {}
    # When the response does carry data, sometimes JSON.parse works, sometimes
    # not. Hence, we need try and if it fails continue untangling the
    # "custom JSON" (=invalid JSON) that was sent.
    else if _.isString data
      try
        data = JSON.parse data
      catch e
        try
          data = eval("(function(){return #{data}})")()
        catch err
          data = new Error 'unable to parse the response'

      # Now, we can unwrap the parsed data
      unwrap data
    else
      return data

module.exports = Sanitizer
