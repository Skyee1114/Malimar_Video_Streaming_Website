angular.module('tv-dashboard').factory 'FavoriteVideos', [
  '$resource'
  ($resource) ->
    'use strict'

    $resource '/favorite_videos/:id.json', {
      id: '@id'
      user: '@user'
    }, {
      create: method: "POST"
      delete: method: "DELETE"
    }
]
