angular.module('tv-dashboard').factory 'Thumbnails', [
  '$resource', '$cacheFactory'
  ($resource, $cacheFactory) ->
    'use strict'

    $resource '/thumbnails.json', {
      container: '@container'
      limit: '@limit'
    }, {
      get:
        cache: $cacheFactory("Thumbnails.list")
        method: "GET"
    }
]
