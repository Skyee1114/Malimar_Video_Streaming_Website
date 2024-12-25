angular.module('tv-dashboard').factory 'Episodes', [
  '$resource', ($resource) ->
    'use strict'

    $resource '/episodes/:id.json', {
      id: '@id',
      show: '@show'
    }, {}
]
