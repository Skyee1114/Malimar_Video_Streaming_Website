angular.module('tv-dashboard').factory 'Invitations', [
  '$resource', ($resource) ->
    'use strict'

    $resource '/invitations.json', {}, {
      create: method: "POST"
    }
]
