angular.module('tv-dashboard').config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state "account.setup", {
      url: "/setup/:token",
      templateUrl: 'account/setup.html',
      controller: 'AccountSetupCtrl'
    }
]
