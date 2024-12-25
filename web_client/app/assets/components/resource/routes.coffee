angular.module('tv-dashboard').config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state "resource", {
      abstract: true,
      template: '<ui-view/>'
    }
]
