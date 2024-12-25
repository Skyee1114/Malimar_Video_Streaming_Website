angular.module('tv-dashboard').controller 'AccountEditCtrl', [
  '$scope', '$stateParams', '$state', 'toaster', 'Users', 'Sessions'
  ($scope, $params, $state, toaster, Users, Sessions) ->
    'use strict'

    Sessions.tokenAuth $params.token

    Users.get id: Sessions.user.id, (response) ->
      $scope.user = response.users

    $scope.submit = ->
      Users.update { id: $scope.user.id, users: $scope.user },
        (response) ->
          toaster.pop "success", "Updated", "Your account information has been updated"
          $state.go "account.settings"
          return
        ,
        (error_response) ->
          $scope.error = error_response.data.errors
          return
      return

    return
]
