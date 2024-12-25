angular.module('tv-dashboard').factory 'Permissions', [
  '$resource', '$cacheFactory'
  ($resource, $cacheFactory) ->
    'use strict'

    $resource '/permissions.json', {
      limit: "@limit"
      user: "@user"
      filter: "@filter"
    }, {
      get:
        cache: $cacheFactory("Permissions.user")
        method: "GET"
    }
]
