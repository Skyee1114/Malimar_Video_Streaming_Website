app = angular.module('tv-dashboard')
app.factory "apiVersionInterceptor", ->
  request: (config) ->
    config.headers["API-VERSION"]  = "v1"
    config

app.config [
  '$httpProvider'
  ($httpProvider) ->
    $httpProvider.interceptors.push 'apiVersionInterceptor'
]
