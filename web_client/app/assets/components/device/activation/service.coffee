angular.module('tv-dashboard').factory 'DeviceActivation', [
  '$resource', ($resource) ->
    'use strict'

    $resource '/device/activation_requests.json', {}, {
      create: method: "POST"
    }
]
