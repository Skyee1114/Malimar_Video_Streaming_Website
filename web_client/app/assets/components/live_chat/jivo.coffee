angular.module('tv-dashboard').directive 'liveChatJivo', [
  '$window', 'angularLoad', 'toaster', 'Sessions'
  ($window, angularLoad, toaster, Sessions) ->
    'use strict'
    restrict: 'E'
    link: (scope, element, attrs) ->
      angularLoad.loadScript("//code.jivosite.com/script/widget/UUXUGcjwwz")
        .then ->
          $window.jivo_onLoadCallback = ->
            email = Sessions.user.email

            customer_data = []

            if Sessions.isUserSubscribed()
              customer_data.push content: 'Premium subscription'

            if Sessions.isUserAGuest()
              customer_data.push content: 'Guest user'

            if Sessions.isUserRegistered()
              $window.jivo_api.setContactInfo(email: email, name: email)
              customer_data.push content: 'Registered user'

            $window.jivo_api.setCustomData customer_data

          return
        .catch ->
          toaster.pop "error", "There was some error loading Live Chat"
          return
      return
]
