angular.module('tv-dashboard').factory 'Users', [
  '$resource', ($resource) ->
    'use strict'

    $resource '/users/:id.json', {
      id: '@id'
    }, {
      create: method: "POST"
      update: method: "PUT"
    }
]
