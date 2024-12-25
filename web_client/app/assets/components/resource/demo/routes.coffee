angular.module('tv-dashboard').config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state "resource.demo", {
      abstract: true,
      template: '<ui-view/>'
    }
    .state "resource.demo.video", {
      url: "/demo/?url",
      templateUrl: 'video_player.html'
      controller: 'DemoVideoCtrl'
    }
]
