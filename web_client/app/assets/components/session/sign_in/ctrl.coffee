angular.module('tv-dashboard').controller 'SignInCtrl', [
  '$window', '$scope', '$state', 'toaster', 'Sessions', 'Facebook',  'Google', 'Navigator'
  ($window, $scope, $state, toaster, Sessions, Facebook, Google, Navigator) ->
    'use strict'
    that = this
    $scope.user_session = {}

    $scope.submit = ->
      Sessions.basicAuthentication($scope.user_session)
        .then loginSuccessful, loginFalied
      return

    $scope.FBLogin = ->
      Sessions.facebookAuthentication(Facebook)
        .then loginSuccessful, loginFalied
      return

    $scope.GoogleLogin = (response)->
      Sessions.googleAuthentication(Google, response)
        .then loginSuccessful, loginFalied
      return

    loginSuccessful = (user) ->
      Navigator.return() or $state.go "resource.dashboard"
      return

    loginFalied = (error_response) ->
      $scope.error = 'password'
      return

    return
]
