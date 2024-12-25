angular.module('tv-dashboard').config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state "resource.tests", {
      template: '<ui-view/>'
      abstact: true
    }
    .state "resource.tests.video", {
      url: "/tests/:id?grid",
      templateUrl: 'test_video_player.html'
      controller: 'ChannelVideoCtrl'
    }
]
