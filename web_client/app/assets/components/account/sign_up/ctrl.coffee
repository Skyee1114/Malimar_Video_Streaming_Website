angular.module('tv-dashboard').controller 'SignUpCtrl', [
  '$scope', '$state', 'toaster', 'Users', 'Facebook',  'Google', 'Sessions', 'Navigator'
  ($scope, $state, toaster, Users, Facebook, Google, Sessions, Navigator) ->
    'use strict'

    $scope.user = {}

    $scope.submit = ->
      Sessions.clear()
      Users.create { users: $scope.user, include: 'session' },
        (response) ->
          toaster.pop "success", "Succesfully registered", "Your account has been created"
          Sessions.signIn response.users.links.session
          $state.go "account.subscribe.form"
          return
        ,
        (error_response) ->
          $scope.error = error_response.data.errors
          return
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
      if Sessions.isUserSubscribed()
        Navigator.return() or $state.go "resource.dashboard"
      else
        $state.go "account.subscribe.form"
      return

    loginFalied = (error_response) ->
      return

    return
]
