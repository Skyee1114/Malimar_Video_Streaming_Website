angular.module('tv-dashboard').controller 'ShowcaseCtrl', [
  '$scope', 'Grids', 'Thumbnails', 'lodash'
  ($scope, Grids, Thumbnails, lodash) ->
    'use strict'

    $scope.categories = undefined
    $scope.thumbnails = []

    Grids.get { dashboard: 'Slider', include: 'thumbnails' }, (resource) ->
      $scope.categories = resource.grids
      $scope.showcase $scope.categories[0]
      return

    $scope.showcase = (exibit) ->
      $scope.category = exibit
      $scope.thumbnails = lodash.chunk exibit.links.thumbnails, 2
      return

    $scope.scroll_options = {
      element_width: 415
      template_url: 'showcase/display.html'
    }
    return
]
