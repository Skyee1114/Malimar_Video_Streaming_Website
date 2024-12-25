angular.module('tv-dashboard').config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state "resource.dashboard", {
      url: "/dashboards/:id",
      templateUrl: 'resource/dashboard.html',
      controller: 'DashboardCtrl',
      params:
        id: 'HomeGrid'
    }

    .state "resource.thai_dashboard", {
      url: "/thai",
      templateUrl: 'resource/dashboard.html',
      controller: 'DashboardCtrl',
      params:
        id: 'thai'
    }
    .state "resource.lao_dashboard", {
      url: "/lao",
      templateUrl: 'resource/dashboard.html',
      controller: 'DashboardCtrl',
      params:
        id: 'lao'
    }

    .state "resource.khmer_dashboard", {
      url: "/khmer",
      templateUrl: 'resource/dashboard.html',
      controller: 'DashboardCtrl',
      params:
        id: 'khmer'
    }

    .state "resource.hmong_dashboard", {
      url: "/hmong",
      templateUrl: 'resource/dashboard.html',
      controller: 'DashboardCtrl',
      params:
        id: 'hmong'
    }
]
