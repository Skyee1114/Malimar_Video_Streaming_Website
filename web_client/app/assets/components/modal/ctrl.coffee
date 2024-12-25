angular.module('tv-dashboard').controller 'ModalCtrl', [
  '$scope', '$modalInstance'
  ($scope, $modalInstance) ->
    $scope.close = ->
      $modalInstance.dismiss('cancel')
      return

    return
]
