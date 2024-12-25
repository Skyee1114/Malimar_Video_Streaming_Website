angular.module('tv-dashboard').factory 'FlowPlayerService', [
  'angularLoad', 'JWPlayerService', '$rootScope', '$window'
  (angularLoad, JWPlayerService, $root, $window) ->
    'use strict'
    FlowPlayerService = {}

    FlowPlayerService.run = (options) ->
      FlowPlayerService.setup(options)
      return

    FlowPlayerService.setup = (options) ->
      $window.flowplayer.cloud
        .then () ->
          console.log(options.file)
          player = $window.flowplayer('#player', {
            live: options.isLiveStream || false
            src: options.file
            autoplay: false
            muted: false
          })

          return JWPlayerService.setup(options) unless player

          player.play()

          player.on 'error', (e) ->
            return unless e.data
            return if e.data.message == 't.removeClass is not a function'

            extra_elements = angular.element document.querySelector('.video-player__extra')
            extra_elements.css 'display': 'block'

          player.on 'fullscreenenter', ->
            chat = angular.element document.querySelector('#tawkchat-iframe-container')
            chat.addClass 'hide-for-small-up' if chat

            return if document.fullscreenEnabled
            player.webkitEnterFullscreen()

            player.one 'webkitendfullscreen', ->
              player.emit 'fullscreenexit'
              return

            player.on 'ended', ->
              player.webkitExitFullscreen()
              return

          player.on 'fullscreenexit', ->
            chat = angular.element document.querySelector('#tawkchat-iframe-container')
            chat.removeClass 'hide-for-small-up' if chat
            return

          $root.$emit 'player:created', player
          return

        .catch ->
          return JWPlayerService.setup(options)
      return

    FlowPlayerService
]
