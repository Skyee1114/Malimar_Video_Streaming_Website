angular.module('tv-dashboard').factory 'JWPlayerService', [
  '$rootScope', '$window'
  ($root, $window) ->
    'use strict'

    JWPlayerService = {}
    JWPlayerService.run = (options) ->
      return if angular.isUndefined(jwplayer)
      JWPlayerService.setup(options)
      return

    JWPlayerService.setup = (options) ->
      player = $window.jwplayer('player').setup(options)

      player.on 'setupError', ->
        player.remove()
        message = angular.element document.querySelector('.no-adobe-flash')
        message.css 'display': 'block' if message

        error = angular.element document.querySelector('.jw-error')
        error.css 'display': 'none' if error

      player.on 'error', ->
        extra_elements = angular.element document.querySelector('.video-player__extra')
        extra_elements.css 'display': 'block' if extra_elements

      player.on 'fullscreen', ->
        chat = angular.element document.querySelector('#tawkchat-iframe-container')
        chat.toggleClass 'hide-for-small-up' if chat

      $root.$emit 'player:created', player
      return

    JWPlayerService
]
