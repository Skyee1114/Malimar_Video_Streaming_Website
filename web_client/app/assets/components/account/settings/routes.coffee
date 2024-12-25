angular.module('tv-dashboard').config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state "account.settings", {
      url: ""
      templateUrl: 'account/settings.html'
    }
]
