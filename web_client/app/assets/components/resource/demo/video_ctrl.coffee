angular.module('tv-dashboard').controller 'DemoVideoCtrl', [
  '$scope', '$stateParams', '$rootScope', '$window'
  ($scope, $params, $root, $window) ->
    'use strict'

    url = $params.url
    $root.$emit 'page:video'

    $window.document.title = "Demo"

    $scope.video =
      file:       url
      playerUrl:  '//content.jwplatform.com/libraries/Pnf2lgKg.js'
]
