angular.module('tv-dashboard').directive 'digicertSeal', [
  '$window', 'angularLoad'
  ($window, angularLoad) ->
    'use strict'
    restrict: 'E'
    link: (scope, element, attrs) ->
      $window.__dcid = $window.__dcid or []
      $window.__dcid.push [
        'DigiCertClickID_Gibt0VyT'
        '11'
        'l'
        'black'
        'Gibt0VyT'
      ]

      angularLoad.loadScript("https://seal.digicert.com/seals/cascade/seal.min.js")
        .catch ->
          console.log "There was some error loading digicert seal"
          return
      return
    templateUrl: 'form/seals/digicert.html'
]
