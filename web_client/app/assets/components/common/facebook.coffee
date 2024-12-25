angular.module('tv-dashboard').service 'Facebook', [
  '$window', '$q', '$http', 'FACEBOOK_APP_ID', 'angularLoad', 'toaster'
  ($window, $q, $http, FACEBOOK_APP_ID, angularLoad, toaster) ->
    'use strict'

    angularLoad.loadScript("https://connect.facebook.net/en_US/sdk.js")
      .then ->
        $window.FB.init(
          appId: FACEBOOK_APP_ID
          status: false
          cookie: false
          xfbml: true
          version:'v3.3'
        )
        return
      .catch ->
        toaster.pop "error", "There was some error loading Facebook"
        return

    @getAuthToken = ->
      @login()
        .then (response) ->
          if response.status is 'connected'
            response.authResponse.accessToken
          else
            $q.reject response.status


    @login = ->
      deferred = $q.defer()
      $window.FB.login (response) ->
        if !response
          deferred.reject "No response from Facebook"

        else if response.error
          deferred.reject response.error

        else
          deferred.resolve response
      , { scope: 'email', auth_type: 'rerequest' }

      deferred.promise

    return
]
