angular.module('tv-dashboard').directive 'authorizeNetSeal', [
  '$location', '$window', 'angularLoad'
  ($location, $window, angularLoad) ->
    'use strict'
    restrict: 'E'
    scope: {}
    link: (scope, element, attrs) ->
      scope.url = "https://verify.authorize.net/anetseal/?pid=7b7d05c9-e082-45fd-857b-59a1a8dc6364&amp;rurl=" + $location.absUrl()

      scope.verify = ->
        $window.open scope.url, 'AuthorizeNetVerification', 'width=600,height=430,dependent=yes,resizable=yes,scrollbars=yes,menubar=no,toolbar=no,status=no,directories=no,location=yes'
        return

      return
    templateUrl: 'form/seals/authorize_net.html'
]
