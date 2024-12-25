angular.module('tv-dashboard').controller 'RecentlyPlayedCtrl', [
  '$scope', '$state', 'RecentlyPlayed', 'Sessions', 'lodash'
  ($scope, $state, RecentlyPlayed, Sessions, lodash) ->
    'use strict'

    $scope.thumbnails = undefined
    $scope.show_recently_played_videos = false
    return if Sessions.isUserAGuest()

    user = Sessions.user
    RecentlyPlayed.get { user: user.id }, (data) ->
      $scope.grid = {
        title: "Recently Watched"
      }
      $scope.thumbnails = data.recently_played
      $scope.show_recently_played_videos = true if $scope.thumbnails.length > 0
      return

    $scope.remove = (chunk, id) ->
      RecentlyPlayed.delete { id: id },
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
