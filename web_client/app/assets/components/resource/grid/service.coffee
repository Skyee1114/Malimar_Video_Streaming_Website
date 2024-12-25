angular.module('tv-dashboard').factory 'Grids', [
  '$resource', '$cacheFactory'
  ($resource, $cacheFactory) ->
    'use strict'

    $resource '/grids/:id.json', {
      dashboard: '@dashboard',
      include: '@include',
      id: '@id'
    }, {
      get:
        cache: $cacheFactory("Grids.list")
        method: "GET"
    }

]
