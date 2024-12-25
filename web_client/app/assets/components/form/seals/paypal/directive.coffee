angular.module('tv-dashboard').directive 'paypalSeal', [
  '$location', '$window'
  ($location, $window, angularLoad) ->
    'use strict'
    restrict: 'E'
    scope: {}
    link: (scope, element, attrs) ->
      scope.url = "https://www.paypal.com/webapps/mpp/paypal-popup"

      scope.verify = ->
        $window.open scope.url, 'WIPaypal', 'toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=yes, resizable=yes, width=1060, height=700'
        return

      return
    templateUrl: 'form/seals/paypal.html'
]
