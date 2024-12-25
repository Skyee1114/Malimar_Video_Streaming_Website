angular.module('tv-dashboard').directive 'player', [
  'FlowPlayerService', 'JWPlayerService', '$window'
  (FlowPlayerService, JWPlayerService, $window) ->
    'use strict'
    restrict: 'E'
    scope: true
    template: '<div id="player"></div>'
    link: (scope, element, attrs) ->
      selectPlayer = () ->
        return FlowPlayerService if attrs.forceFlowPlayer == "true"
        return JWPlayerService if attrs.forceJwPlayer == "true"

        return FlowPlayerService

      runPlayer = (options) ->
        return unless options
        options = JSON.parse(options)

        player = selectPlayer()
        player.run(options)

      attrs.$observe('playerOptions', runPlayer)
      return
]
