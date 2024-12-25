angular.module('tv-dashboard').controller 'FavoriteVideosCtrl', [
  '$scope', '$state', 'FavoriteVideos', 'Sessions', 'lodash'
  ($scope, $state, FavoriteVideos, Sessions, lodash) ->
    'use strict'

    $scope.thumbnails = undefined
    $scope.show_favorite_videos = false
    return if Sessions.isUserAGuest()

    user = Sessions.user
    FavoriteVideos.get { user: user.id }, (data) ->
      $scope.grid = {
        title: "Favorites"
      }
      $scope.thumbnails = data.favorite_videos
      $scope.show_favorite_videos = true if $scope.thumbnails.length > 0
      return

    $scope.remove = (chunk, id) ->
      FavoriteVideos.delete { id: id, user: user.id },
        (response) ->
          lodash.remove chunk, id: id
          return
        ,
        (error_response) ->
          $scope.error = error_response.data.errors
          return
      return

    return
]
