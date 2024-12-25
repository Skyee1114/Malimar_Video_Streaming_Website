angular.module('tv-dashboard').service 'Navigator', [
  '$cacheFactory', '$location', 'Sessions'
  ($cacheFactory, $location, Sessions) ->
    'use strict'
    @SOURCE_URL = null

    @go = (path) ->
      @SOURCE_URL = $location.url()
      $location.path(path).replace()

    @return = ->
      if @SOURCE_URL
        $location.url(@SOURCE_URL)
        @SOURCE_URL = null
        return true
      else
        return false

    return
]
