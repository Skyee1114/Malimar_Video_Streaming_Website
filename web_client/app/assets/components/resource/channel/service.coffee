angular.module('tv-dashboard').factory 'Channels', [
  '$resource', ($resource) ->
    'use strict'

    $resource '/channels/:id.json', {
      grid: '@grid'
    }, {}
]
