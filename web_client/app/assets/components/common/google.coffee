angular.module('tv-dashboard').service 'Google', [
  '$q'
  ($q) ->
    'use strict'

    @getAuthToken = (response) ->
      deferred = $q.defer()
      deferred.resolve response.credential
      deferred.promise

    return
]
