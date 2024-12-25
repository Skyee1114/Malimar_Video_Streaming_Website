angular.module('tv-dashboard').controller 'DeviceLandingCtrl', [
  '$scope', 'Thumbnails'
  ($scope, Thumbnails) ->
    'use strict'

    $scope.channels = undefined
    params = {
      container: 'LiveTV_Premium_CF'
    }

    Thumbnails.get params, (resource) ->
      $scope.channels = resource.thumbnails
      return

    $scope.dramas = undefined
    params = {
      container: 'Drama_Thai_New_Episodes_CF'
    }

    Thumbnails.get params, (resource) ->
      $scope.dramas = resource.thumbnails
      return

    return
]
