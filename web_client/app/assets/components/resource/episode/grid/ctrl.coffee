angular.module('tv-dashboard').controller 'EpisodeGridCtrl', [
  '$scope', '$state', '$rootScope', 'Episodes', 'lodash'
  ($scope, $state, $root, Episodes, lodash) ->
    'use strict'

    $scope.episodes = undefined
    show_id = $state.params.show

    $root.$emit 'page:video'

    Episodes.get { show: show_id }, (data) ->
      $scope.episodes = lodash.chunk data.episodes, 4
      return

    updateScroller = ->
      $scope.scroll_options =
        element_width: 325
        template_url: 'resource/episode/grid/scroller.html'
        active: $state.params.id
      return

    updateScroller()

    $scope.$on '$stateChangeSuccess', updateScroller
]
