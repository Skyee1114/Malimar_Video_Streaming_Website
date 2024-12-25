angular.module('tv-dashboard').config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state "resource.episodes", {
      templateUrl: 'resource/episode.html'
      abstact: true
    }
    .state "resource.episodes.video", {
      url: "/episodes/:id?show&forceJWPlayer",
      templateUrl: 'video_player.html'
      controller: 'EpisodeVideoCtrl'
    }
]
