angular.module('tv-dashboard').controller 'AccountSettingsInformationCtrl', [
  '$scope', 'Sessions', 'Users'
  ($scope, Sessions, Users) ->
    'use strict'

    Users.get id: Sessions.user.id, (response) ->
      $scope.user = response.users

    return
]
