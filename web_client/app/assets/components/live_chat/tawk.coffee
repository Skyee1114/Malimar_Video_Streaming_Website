angular.module('tv-dashboard').directive 'liveChatTawk', [
  '$window', '$rootScope', 'TAWK_APP_ID', 'angularLoad', 'toaster', 'Sessions'
  ($window, $root, TAWK_APP_ID, angularLoad, toaster, Sessions) ->
    'use strict'
    restrict: 'E'
    link: (scope, element, attrs) ->
      angularLoad.loadScript("https://embed.tawk.to/#{ TAWK_APP_ID }/default")
        .then ->
          setTawkUser Sessions.user
          return
        .catch ->
          toaster.pop "error", "There was some error loading Live Chat"
          return

      $root.$on 'auth:success', (_, user) ->
        setTawkUser user
        return

      setTawkUser = (user) ->
        email = user.email
        $window.Tawk_API = $window.Tawk_API || {}
        $window.Tawk_API.visitor = {
          name: email
          email: email
        }

      return
]
