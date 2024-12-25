angular.module('tv-dashboard').config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state "resource.grid", {
      url: "/grids/:id?dashboard",
      templateUrl: 'resource/grid.html',
      controller: 'GridCtrl'
    }
]
