angular.module('tv-dashboard').factory 'Shows', [
  '$resource', '$cacheFactory'
  ($resource, $cacheFactory) ->
    'use strict'

    $resource '/shows/:id.json', {
      id: '@id'
      include: '@include',
      grid: '@grid'
    }, {
      get:
        cache: $cacheFactory("Shows.list")
        method: "GET"
    }
]
