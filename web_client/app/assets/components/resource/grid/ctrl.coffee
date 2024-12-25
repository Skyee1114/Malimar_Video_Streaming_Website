angular.module('tv-dashboard').controller 'GridCtrl', [
  '$scope', '$stateParams', 'Grids', 'Thumbnails'
  ($scope, $params, Grids, Thumbnails) ->
    'use strict'

    $scope.grid = {}
    $scope.thumbnails = undefined

    params = {
      id: $params.id
      dashboard: $params.dashboard
    }

    Grids.get params, (resource) ->
      $scope.grid = resource.grids
      return

    params = {
      container: $params.id
    }

    Thumbnails.get params, (resource) ->
      $scope.thumbnails = resource.thumbnails
      return

    return
]
