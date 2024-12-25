angular.module('tv-dashboard').directive 'chooseDevice', [
  '$state', '$rootScope' 
  ($state, $root) ->
    'use strict'
    restrict: 'E'
    require: 'ngModel'
    scope:
      device: '=ngModel'
      devices: '='
      required: '@'

    link: (scope, element, attrs, ctrl) ->
      scope.chooseDevice = (available_device) ->
        scope.hasSerial = available_device.type != null
        ctrl.$setViewValue(available_device)
        $root.device = available_device
        scope.serial_number_label = available_device.name + ' serial number'
        scope.serial_number_label += ' (Optional)' if !scope.required

      scope.isSelected = (available_device) ->
        return unless available_device
        available_device == scope.device

      scope.isRokuDevice = (device) ->
        return false unless device
        'Device::Roku' == scope.device.type

      defaultDevice = (collection) ->
        collection[0]

      scope.chooseDevice defaultDevice(scope.devices)

      return
    templateUrl: 'form/choose_device.html'
]
