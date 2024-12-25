angular.module('tv-dashboard').config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state "resource.shows", {
      url: "/shows/:id?grid",
      templateUrl: 'resource/show.html',
      controller: 'ShowsCtrl'
    }
]
