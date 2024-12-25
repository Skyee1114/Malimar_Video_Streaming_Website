angular.module('tv-dashboard').config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state "session.sign_out", {
      url: "/sign_out",
      controller: 'SignOutCtrl'
    }
]
