angular.module('tv-dashboard').factory 'RecentlyPlayed', [
  '$resource'
  ($resource) ->
    'use strict'

    $resource '/recently_played.json', {}, {}
    $resource '/recently_played/:id.json', {
      id: '@id'
    }, {
      delete: method: "DELETE"
    }
]
