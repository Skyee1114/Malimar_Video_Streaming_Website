angular.module('tv-dashboard').config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state "session.sign_in", {
      url: "/sign_in",
      templateUrl: 'session/sign_in.html',
      controller: 'SignInCtrl'
    }
]
