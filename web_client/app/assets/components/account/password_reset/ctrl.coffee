angular.module('tv-dashboard').controller 'PasswordResetCtrl', [
  '$scope', '$state', 'toaster', 'Passwords', 'Sessions'
  ($scope, $state, toaster, Passwords, Sessions) ->
    'use strict'

    $scope.user_password_reset = {}

    $scope.submit = ->
      Sessions.clear()
      Passwords.create { passwords: $scope.user_password_reset },
        (response) ->
          toaster.pop "success", "Email sent to #{ response.passwords.email }", "Check your email to continue"
          $state.go "account.password_reset_sent"
          return
        ,
        (error_response) ->
          toaster.pop "error", "Can not find your account", "Please check your input, contact support or create your account"
          return
      return

    return
]
