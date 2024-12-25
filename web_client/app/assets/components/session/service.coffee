angular.module('tv-dashboard').factory 'Sessions', [
  '$resource', '$state', '$rootScope', '$window', '$http', '$q', '$cacheFactory', 'toaster', 'SessionStorage'
  ($resource, $state, $root, $window, $http, $q, $cacheFactory, toaster, SessionStorage) ->
    'use strict'

    Sessions = $resource '/sessions.json', {
      include: "@include"
    }, {
      create:
        method: "POST"
    }

    guest_user = { id: 'guest', email: 'guest', origin: 'guest'}

    Sessions.basicAuthentication = (session)->
      toaster.clear()
      Sessions.clear()
      login = session.login || ''
      password = session.password || ''
      credentials =  login + ':' + password
      encoded_credentials = $window.btoa credentials
      $http.defaults.headers.common.Authorization = 'Basic ' + encoded_credentials

      Sessions.create().$promise
        .then (response) ->
          Sessions.signIn response.sessions

        , (error_response) ->
          Sessions.clear()
          toaster.pop "info", "Forgot password?", "You can <a href='/account/password_reset'>reset it here</a>.", 15000, 'trustedHtml'
          $q.reject error_response

    Sessions.facebookAuthentication = (Facebook)->
      toaster.clear()
      Sessions.clear()
      Facebook.getAuthToken()
        .then (token)->
          $http.defaults.headers.common.Authorization = 'Facebook ' + token

          Sessions.create().$promise
            .then (response) ->
              Sessions.signIn response.sessions

            , (error_response) ->
              Sessions.clear()
              toaster.pop "error", "Facebook login error", "Try again or contact support", 15000
              $q.reject error_response

    Sessions.googleAuthentication = (Google, response)->
      toaster.clear()
      Sessions.clear()
      Google.getAuthToken(response)
        .then (token)->
          $http.defaults.headers.common.Authorization = 'Google ' + token

          Sessions.create().$promise
            .then (response) ->
              Sessions.signIn response.sessions

            , (error_response) ->
              Sessions.clear()
              toaster.pop "error", "Google login error", "Try again or contact support", 15000
              $q.reject error_response

    Sessions.tokenAuth = (token) ->
      if token
        session = { id: token }

        try
          Sessions.signIn session
        catch
          $state.go "account.sign_up"
          return
      return

    Sessions.signIn = (session)->
      SessionStorage.set 'token', session.id
      clearPrivateCache()
      loadUser()

      unless Sessions.isUserAGuest()
        toaster.pop "info", "Signed in", "Welcome #{ Sessions.user.login }", 3000
        $root.$emit 'auth:success', Sessions.user
      else
        toaster.pop "error", "Sign in error", "Incorrect token"
        throw "Incorrect token"

      return Sessions.user

    Sessions.signOut = ->
      Sessions.clear()
      toaster.pop "info", "Signed out"
      return

    Sessions.clear = ->
      $http.defaults.headers.common.Authorization = undefined
      SessionStorage.remove 'token'
      loadGuestUser()
      return

    Sessions.isUserRegistered = ->
      Sessions.user.origin == 'local'

    Sessions.isUserAGuest = ->
      Sessions.user.origin == 'guest'

    Sessions.isUserSubscribed = ->
      Sessions.user.premium

    loadUser = ->
      token = SessionStorage.fetch 'token'
      return loadGuestUser() unless token

      try
        encoded_user = token.split('.')[1]
        data = JSON.parse urlBase64Decode(encoded_user)

        Sessions.user = data['user']
        $root.$emit 'auth:update', Sessions.user

      catch e
        Sessions.clear()

      return

    loadGuestUser = ->
      Sessions.user = guest_user
      $root.$emit 'auth:update', Sessions.user
      return

    urlBase64Decode = (str) ->
      $window.atob str.replace('-', '+').replace('_', '/')

    clearPrivateCache = ->
      permission_cache = $cacheFactory.get "Permissions.user"
      permission_cache.removeAll() if permission_cache
      return

    loadUser()
    Sessions
]
