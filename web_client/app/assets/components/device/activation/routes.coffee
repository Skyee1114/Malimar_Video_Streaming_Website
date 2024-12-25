angular.module('tv-dashboard').config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state 'device.activation', {
      url: '/activation',
      templateUrl: 'device/activation.html',
      abstract: true
    }
    .state 'device.activation.form', {
      url: '',
      templateUrl: 'device/activation/form.html',
      controller: 'DeviceActivationCtrl',
    }
]
