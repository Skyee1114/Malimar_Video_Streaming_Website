angular.module('tv-dashboard').config [
  '$urlRouterProvider',
  ($urlRouterProvider) ->
    $urlRouterProvider.otherwise '/'
    $urlRouterProvider.when '/', [
      '$state',
      ($state) ->
        $state.go 'resource.dashboard', { id: "HomeGrid" }, location: false
        return true
    ]
]
