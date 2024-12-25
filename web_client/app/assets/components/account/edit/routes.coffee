angular.module('tv-dashboard').config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state "account.edit", {
      url: "/edit/{token}",
      templateUrl: 'account/edit.html',
      controller: 'AccountEditCtrl'
      params:
        token:
          squash: true
    }
]
