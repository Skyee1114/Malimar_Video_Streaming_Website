angular.module('tv-dashboard').controller 'DeviceActivationCtrl', [
  '$scope', '$state', 'toaster', 'Sessions', 'Navigator', 'DeviceActivation', 'FormHelper', 'lodash'
  ($scope, $state, toaster, Sessions, Navigator, DeviceActivation, FormHelper, lodash) ->
    'use strict'

    unless Sessions.isUserRegistered()
      toaster.pop 'warning', 'Account required', 'An account is required to request a Trial.'
      Navigator.go '/sign_in'
      return

    $scope.device_activation_request = {}

    $scope.referrals = [
      'TV Ad'
      'Friend'
      'Internet Search'
    ]

    $scope.services = [
      {
        id:   'tech'
        name: 'Technical Support'
      }, {
        id:   'trial'
        name: '30 Day trial activation request'
      }
    ]

    $scope.devices = [
      {
        id: 1
        type: 'Device::Roku'
        name: 'Roku'
        validation: {
          length: '6 or 12'
          mask: '******?*?*?*?*?*?*?'
        }
      },
      {
        id: 2
        type: 'Device::FireTv'
        name: 'Fire TV'
        validation: {
          length: 16
          mask: '****************'
        }
      }
    ]


    $scope.plan = {}
    $scope.plans = [{
      id: 'free'
      name: '30 Day Premium Trial'
      cost: '0.00'
      interval_price: '0.00'
      includes_roku_content: true
      includes_web_content: false
    }]

    $scope.$watch 'device_activation_request.country', (country_code) ->
      $scope.zip_code_name = FormHelper.zipCodeName country_code

    $scope.submit = ->
      request_params = lodash.extend {}, $scope.device_activation_request
      request_params['referral'] += " '#{ request_params['friend_name'] }'" if request_params['friend_name']

      request_params['links'] = {
        device: {
          serial_number: $scope.device.serial_number
          type: $scope.device.type
        }
      }

      DeviceActivation.create activation_requests: request_params,
        (response) ->
          toaster.pop "success", "Request sent"
          $state.go "device.add_channel.step1"
          return
        ,
        (error_response) ->
          $scope.error = error_response.data.errors
          return
      return

    return
]
