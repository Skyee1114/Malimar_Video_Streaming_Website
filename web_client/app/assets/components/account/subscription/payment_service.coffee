angular.module('tv-dashboard').factory 'SubscriptionPayment', [
  '$resource', ($resource) ->
    'use strict'

    $resource '/subscription_payments.json', {
      include: "@include"
    }, {
      create: method: "POST"
    }
]
