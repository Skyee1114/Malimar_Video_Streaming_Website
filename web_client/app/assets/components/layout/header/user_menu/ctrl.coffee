angular.module('tv-dashboard').controller 'UserMenuCtrl', [
  '$scope', '$state', '$modal'
  ($scope, $state, $modal) ->
    'use strict'

    $scope.$root.$on '$stateChangeSuccess', (event) ->
      $scope.current_dashboard = $state.params.id
      return

    return
]
