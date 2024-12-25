angular.module('tv-dashboard').controller 'AccountSettingsSubscriptionCtrl', [
  '$scope', '$filter', 'toaster', 'lodash', 'Sessions', 'Permissions'
  ($scope, $filter, toaster, lodash, Sessions, Permissions) ->
    'use strict'

    user_id = Sessions.user.id
    $scope.has_subscription = false

    Permissions.get { user: user_id, 'filter[active]': true },
      (resource) ->
        $scope.permissions = resource.permissions
        $scope.premium = lodash.find $scope.permissions, { allow: 'premium' }
        $scope.has_subscription = !!$scope.premium
        if $scope.has_subscription
          $scope.days_on_premium = daysLeft $scope.premium.expires_at
        return
      ,
      (error) ->
        toaster.error 'Network error', 'Unable to load subscription'

    daysLeft = (date) ->
      oneDay = 24*60*60*1000
      Math.round((Date.parse(date) - new Date() ) / oneDay)

    return
]
