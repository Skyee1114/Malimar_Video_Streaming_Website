angular.module('tv-dashboard').controller 'ShowsCtrl', [
  '$scope', '$stateParams', '$window', 'Shows',
  ($scope, $params, $window, Shows) ->
    'use strict'

    $scope.episodes = []

    id = $params.id
    grid = $params.grid

    Shows.get { id }, { grid, include: "episodes" }, (resource) ->
      $scope.show = resource.shows

      $window.document.title = $scope.show.title
      $scope.episodes = resource.shows.links.episodes
      return

    return
]
