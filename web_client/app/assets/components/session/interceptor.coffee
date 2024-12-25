app = angular.module('tv-dashboard')
app.factory 'authInterceptor', [
  '$q', 'toaster', '$rootScope', 'SessionStorage'
  authInterceptor = ($q, toaster, $root, SessionStorage) ->
    'use strict'

    request: (config) ->
      config.headers = config.headers || {}
      if token = SessionStorage.fetch('token')
        config.headers.Authorization = 'Bearer ' + token
      config

    responseError: (rejection) ->
      switch rejection.status
        when 401 then $root.$emit 'auth:unauthorized', rejection
        when 403 then $root.$emit 'auth:forbidden', rejection
        when 404 then $root.$emit 'server:not_found', rejection
        when 409 then $root.$emit 'auth:conflict', rejection
        when 422 then $root.$emit 'data:invalid', rejection
        when 429, 503 then $root.$emit 'server:attack', rejection
        when 500 then $root.$emit 'server:error', rejection
      $q.reject rejection
]

app.config [
  '$httpProvider',
  ($httpProvider) ->
    $httpProvider.interceptors.push 'authInterceptor'
]
