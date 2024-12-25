angular.module('tv-dashboard').config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state "account.invitation_sent", {
      url: "/invitation_sent",
      templateUrl: 'account/sign_up/invitation_sent.html',
    }
]
