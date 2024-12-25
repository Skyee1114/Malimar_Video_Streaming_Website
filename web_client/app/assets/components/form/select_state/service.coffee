angular.module('tv-dashboard').factory 'States', [
  '$resource', '$cacheFactory'
  ($resource, $cacheFactory) ->
    'use strict'

    $resource '/states.json', {
      country: '@country'
    }, {
      get:
        cache: $cacheFactory("States")
        method: "GET"
    }
]
