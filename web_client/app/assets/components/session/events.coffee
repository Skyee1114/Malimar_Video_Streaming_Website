angular.module('tv-dashboard').run [
  '$state', '$rootScope', '$location', '$window', 'toaster', 'Sessions', 'Navigator'
  ($state, $root, $location, $window, toaster, Sessions, Navigator) ->
    'use strict'

    $root.$on 'auth:forbidden', (_, rejection) ->
      if Sessions.isUserRegistered()
        Navigator.go '/account/subscribe'
        toaster.pop 'warning', 'Premium subscription required', 'Subscription not active, please renew or purchase subscription to watch'
      else
        Navigator.go '/account/pricing'
        toaster.pop 'warning', 'Registration required', 'Sign in or Sign up to continue'
      return

    $root.$on 'auth:conflict', (_, rejection) ->
      toaster.pop 'warning', 'Authentication error', 'Only two sessions per account are allowed. Make sure you did not share your account data with others'
      Sessions.clear()
      $state.go 'session.sign_in'
      return

    $root.$on 'auth:unauthorized', (_, rejection) ->
      toaster.pop 'warning', 'Authentication error', 'Invalid or expired credentials. Sign in again'
      Sessions.clear()
      $state.go 'session.sign_in'
      return

    # $root.$on 'auth:success', (_, user) ->

    return
]
