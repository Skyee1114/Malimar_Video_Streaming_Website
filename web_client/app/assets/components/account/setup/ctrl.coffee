angular.module('tv-dashboard').controller 'AccountSetupCtrl', [
  '$scope', '$stateParams', '$state', 'toaster', 'Users', 'Sessions'
  ($scope, $params, $state, toaster, Users, Sessions) ->
    'use strict'

    Sessions.tokenAuth $params.token
    $scope.user = { email: Sessions.user.email }

    $scope.submit = ->
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

    return
]
