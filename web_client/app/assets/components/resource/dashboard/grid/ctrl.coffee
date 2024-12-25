angular.module('tv-dashboard').controller 'DashboardGridCtrl', [
  '$scope', '$state', 'Thumbnails'
  ($scope, $state, Thumbnails) ->
    'use strict'

    $scope.thumbnails = undefined
    grid_id = $scope.grid.id

    Thumbnails.get { container: grid_id }, (data) ->
      $scope.thumbnails = data.thumbnails
      return

    return
]
