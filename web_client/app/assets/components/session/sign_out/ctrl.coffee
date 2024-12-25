angular.module('tv-dashboard').controller 'SignOutCtrl', [
  '$state', 'Sessions'
  ($state, Sessions) ->
    'use strict'

    Sessions.signOut()
    $state.go "session.sign_in"

    return
]
