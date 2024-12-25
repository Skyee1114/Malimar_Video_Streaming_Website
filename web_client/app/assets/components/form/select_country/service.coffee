angular.module('tv-dashboard').factory 'Countries', [
  '$resource', '$cacheFactory'
  ($resource, $cacheFactory) ->
    'use strict'

    $resource '/countries.json', {}, {
      get:
        cache: $cacheFactory("Countries")
        method: "GET"
    }
]
