angular.module('tv-dashboard').factory 'Plans', [
  '$resource', ($resource) ->
    'use strict'

    $resource '/plans.json', {}, {}
]
