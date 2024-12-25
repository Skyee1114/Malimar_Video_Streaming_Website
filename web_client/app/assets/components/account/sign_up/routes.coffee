angular.module('tv-dashboard').config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state "account.sign_up", {
      url: "/sign_up",
      templateUrl: 'account/sign_up.html',
      controller: 'SignUpCtrl'
    }
]
