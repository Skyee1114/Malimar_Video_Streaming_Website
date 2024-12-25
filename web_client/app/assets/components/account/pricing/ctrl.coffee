angular.module('tv-dashboard').controller 'PricingCtrl', [
  '$scope', '$state', 'Plans', 'Sessions'
  ($scope, $state, Plans, Sessions) ->
    'use strict'

    if Sessions.isUserRegistered()
      $state.go "account.subscribe.form"

    $scope.plans = []

    Plans.get (resource) ->
      $scope.plans = resource.plans
      return

    return
]
