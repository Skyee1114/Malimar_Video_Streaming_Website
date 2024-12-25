angular.module('tv-dashboard').directive 'paypalButton', [
  '$document', '$sce', 'PP_SUBMIT_URL', 'PP_CALLBACK_URL', 'PP_MERCHANT_ID'
  ($document, $sce, PP_SUBMIT_URL, PP_CALLBACK_URL, PP_MERCHANT_ID) ->
    'use strict'
    restrict: 'E'
    scope:
      amount: '='
      name: '='
      number: '='
      phone: '='
      serial_number: '=serialNumber'
      device_type: '=deviceType'
      user_id: '=userId'
      caption: '@'
      commonForm: '='
      ppForm: '='
    link: (scope, element, attrs) ->
      trustUrl = (url) ->
        $sce.trustAsResourceUrl url

      scope.pp_submit_url   = trustUrl PP_SUBMIT_URL
      scope.pp_callback_url = trustUrl PP_CALLBACK_URL
      scope.pp_merchant_id  = PP_MERCHANT_ID

    templateUrl: 'form/paypal_button.html'
]
