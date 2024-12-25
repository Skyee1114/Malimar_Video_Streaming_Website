angular.module('tv-dashboard').config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state "resource.channels", {
      templateUrl: 'resource/channel.html'
      abstact: true
    }
    .state "resource.channels.video", {
      url: "/channels/:id?grid&forceJWPlayer",
      templateUrl: 'video_player.html'
      controller: 'ChannelVideoCtrl'
    }
]
