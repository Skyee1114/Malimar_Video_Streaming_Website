angular.module('tv-dashboard').config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state "watchlist", {
      url: "/watchlist",
      templateUrl: 'watchlist.html',
      controller: 'WatchlistCtrl'
    }
]
