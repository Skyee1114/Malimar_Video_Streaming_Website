angular.module('tv-dashboard').controller 'ChannelGridCtrl', [
  '$scope', '$state', '$rootScope', 'Thumbnails'
  ($scope, $state, $root, Thumbnails) ->
    'use strict'

    $scope.thumbnails = undefined

    updateScroller = ->
      $scope.scroll_options =
        template_url: 'resource/channel/grid/scroller.html'
        active: $state.params.id

      return

    loadThumbnails = (container) ->
      Thumbnails.get { container: container  }, (data) ->
        $scope.thumbnails = data.thumbnails
        return


    if $state.params.grid
      loadThumbnails $state.params.grid
    else
      $root.$on 'channel:loaded', (_, resource) ->
        loadThumbnails resource.channels.links.container.id
        return

    updateScroller()
    $scope.$on '$stateChangeSuccess', updateScroller
]
