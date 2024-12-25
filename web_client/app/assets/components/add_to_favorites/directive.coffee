angular.module('tv-dashboard').directive 'addToFavorites', [
  '$window', 'Sessions', 'FavoriteVideos'
  ($window, Sessions, FavoriteVideos) ->
    'use strict'

    restrict: 'E'
    scope: true
    templateUrl: 'add_to_favorites.html'

    link: (scope, element, attrs) ->
      user = Sessions.user

      scope.addToFavorites = ->

        request_params = {
          links:  {
            user: user.id,
            video: scope.video.id,
            container: scope.video.container_id
          }
        }

        FavoriteVideos.create { favorite_videos: request_params },
          (response) ->
            button = angular.element document.querySelector('.add-to-favorites__button')
            result = angular.element document.querySelector('.add-to-favorites__done')
            button.css 'display': 'none'
            result.css 'display': 'block'
            return
          ,
          (error_response) ->
            return
        return
      return
]
