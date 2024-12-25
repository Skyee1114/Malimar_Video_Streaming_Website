angular.module('tv-dashboard').config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state 'device.landing', {
      url: ''
      templateUrl: 'device/landing.html'
      controller: 'DeviceLandingCtrl'
    }

    # backward compatibility
    .state 'roku.landing', {
      url: ''
      redirectTo: 'device.landing'
    }
]
