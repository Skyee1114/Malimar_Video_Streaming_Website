angular.module('tv-dashboard').config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state "account.password_reset", {
      url: "/password_reset"
      templateUrl: 'account/password_reset.html'
      controller: 'PasswordResetCtrl'
    }

    .state "account.password_reset_sent", {
      url: "/password_reset/sent"
      templateUrl: 'account/password_reset/sent.html'
      controller: 'PasswordResetCtrl'
    }
]
