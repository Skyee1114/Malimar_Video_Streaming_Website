angular.module('tv-dashboard').factory 'Passwords', [
  '$resource', ($resource) ->
    'use strict'

    $resource '/passwords.json', {}, {
      create: method: "POST"
    }
]
