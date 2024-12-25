angular.module('tv-dashboard').controller 'ChannelVideoCtrl', [
  '$scope', '$stateParams', '$rootScope', '$window', 'Channels'
  ($scope, $params, $root, $window, Channels) ->
    'use strict'

    id = $params.id
    grid = $params.grid

    $root.$emit 'page:video'

    Channels.get { id: id, grid: grid, include: 'container' }, (resource) ->
      $root.$emit 'channel:loaded', resource
      $scope.channel = resource.channels
      $window.document.title = $scope.channel.title

      $scope.forceJWPlayer = $params.forceJWPlayer == "true"

      $scope.video =
        id:                $scope.channel.id
        container_id:      grid
        file:              $scope.channel.stream_url
        image:             $scope.channel.background_image.hd || $scope.channel.cover_image.hd
        title:             $scope.channel.title
        synopsis:          $scope.channel.synopsis
        background_image:  $scope.channel.background_image.hd
        playerUrl:         $scope.channel.player_url
        isLiveStream:      true

]
