angular.module('tv-dashboard').config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state 'device.add_channel', {
      url: '/add_channel'
      templateUrl: 'device/add_channel.html'
      abstract: true
    }
    .state 'device.add_channel.step1', { url: '/step1', templateUrl: 'device/add_channel/step1.html' }
    .state 'device.add_channel.step2', { url: '/step2', templateUrl: 'device/add_channel/step2.html' }
    .state 'device.add_channel.step3', { url: '/step3', templateUrl: 'device/add_channel/step3.html' }
    .state 'device.add_channel.step4', { url: '/step4', templateUrl: 'device/add_channel/step4.html' }
    .state 'device.add_channel.step5', { url: '/step5', templateUrl: 'device/add_channel/step5.html' }
    .state 'device.add_channel.step6', { url: '/step6', templateUrl: 'device/add_channel/step6.html' }

    .state 'device.add_premium_channel', {
      url: '/add_premium_channel'
      templateUrl: 'device/add_channel/premium.html'
      abstract: true
    }
    .state 'device.add_premium_channel.step1', { url: '/step1', templateUrl: 'device/add_channel/step1.html' }
    .state 'device.add_premium_channel.step2', { url: '/step2', templateUrl: 'device/add_channel/step2.html' }
    .state 'device.add_premium_channel.step3', { url: '/step3', templateUrl: 'device/add_channel/step3.html' }
    .state 'device.add_premium_channel.step4', { url: '/step4', templateUrl: 'device/add_channel/step4.html' }
    .state 'device.add_premium_channel.step5', { url: '/step5', templateUrl: 'device/add_channel/step5.html' }
    .state 'device.add_premium_channel.step6', { url: '/step6', templateUrl: 'device/add_channel/step6.html' }
]
