angular.module('tv-dashboard').run [
  '$rootScope', '$window', '$location', '$state', '$anchorScroll', 'toaster'
  ($root, $window, $location, $state, $anchorScroll, toaster) ->
    'use strict'

    $root.is_busy = false

    $root.$on 'busy.begin', (_, args) ->
      $root.is_busy = true
      return

    $root.$on 'busy.end', (_, args) ->
      if args.remaining <= 0
        $root.is_busy = false
      return

    $root.$on 'data:invalid', (_, rejection) ->
      title = rejection.data.errors.title
      explanation = rejection.data.errors.detail
      toaster.pop 'warning', title, explanation
      return

    $root.$on 'server:error', (_, rejection) ->
      title = 'Internal server error'
      toaster.pop 'error', title
      return

    $root.$on 'server:not_found', (_, rejection) ->
      if rejection.config.method == 'GET'
        title = 'Resource not found'
        toaster.pop 'warning', title
        $state.go 'resource.dashboard'
      return


    $root.$on 'server:attack', (_, rejection) ->
      title = 'Blocked'
      explanation = 'Wait several minutes before continue'
      toaster.pop 'error', title, explanation
      return

    $root.$on '$stateChangeSuccess', (event) ->
      return if !$window.ga
      $window.ga 'send', 'pageview', page: $location.url()
      return

    $root.$on '$stateChangeSuccess', (event) ->
      $root.robots_index_directive = 'index'
      return

    $root.$on 'page:video', (event) ->
      $root.robots_index_directive = 'noindex'
      return

    $root.$on '$stateChangeStart', (event, to, params) ->
      if to.redirectTo
        event.preventDefault()
        $state.go to.redirectTo, params, { location: 'replace' }

    $root.$on 'player:created', (_, player) ->
      $root.last_player = player

    $root.$on '$stateChangeStart', (event, to, params) ->
      if $window.flowplayer && $window.flowplayer.instances
        $window.flowplayer.instances.forEach (instance) ->
          instance.pause()
          instance.destroy()

      if $root.last_player && $root.last_player.stop
        $root.last_player.stop()
        $root.last_player.remove()
        $root.last_player = undefined

    # $stateChangeSuccess
    scrollOn = (state_change_method) ->
      orginal_method = $window.window.history[state_change_method]

      $window.window.history[state_change_method] = ->
        retval = orginal_method.apply this, Array::slice.call(arguments)
        $anchorScroll()
        retval

      return

    scrollOn 'pushState'
    scrollOn 'replaceState'
    return
]
