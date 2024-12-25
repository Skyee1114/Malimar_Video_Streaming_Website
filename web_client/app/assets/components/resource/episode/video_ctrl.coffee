angular.module('tv-dashboard').controller 'EpisodeVideoCtrl', [
  '$scope', '$stateParams', '$rootScope', '$window', 'Episodes'
  ($scope, $params, $root, $window, Episodes) ->
    'use strict'

    id = $params.id
    show = $params.show

    $root.$emit 'page:video'

    Episodes.get { id }, { show }, (resource) ->
      $scope.episode = resource.episodes
      $window.document.title = $scope.episode.title

      $scope.forceJWPlayer = $params.forceJWPlayer == "true"

      $scope.video =
        id:                $scope.episode.id
        container_id:      show
        file:              $scope.episode.stream_url
        image:             $scope.episode.background_image.hd || $scope.episode.cover_image.hd
        title:             $scope.episode.title
        synopsis:          $scope.episode.synopsis
        background_image:  $scope.episode.background_image.hd
        playerUrl:         $scope.episode.player_url
]
