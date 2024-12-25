angular.module('tv-dashboard').controller 'SidebarCtrl', [
  '$scope', '$rootScope', 'Sessions'
  ($scope, $root, Sessions) ->
    'use strict'

    $scope.resources = undefined
    $scope.sidebar_disabled = true

    $root.$on 'dashboard:loaded', (_, resource) ->
      $scope.resources = resource.grids
      $scope.sidebar_disabled = false
      return

    $scope.toggleSidebar = ->
      $scope.sidebar_collapsed = !$scope.sidebar_collapsed
      return

    # FIXME: move to own controller
    setUser = (user) ->
      $scope.current_user = user
      $scope.is_user_a_guest = Sessions.isUserAGuest()
      $scope.is_user_registered = Sessions.isUserRegistered()
      $scope.is_free = ! Sessions.isUserSubscribed()
      $scope.is_premium = Sessions.isUserSubscribed()
      return

    $scope.$root.$on 'auth:update', (_, user) ->
      setUser(user)
      return

    setUser(Sessions.user)


    return
]
