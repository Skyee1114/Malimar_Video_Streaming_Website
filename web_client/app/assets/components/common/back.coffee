angular.module('tv-dashboard').directive "back", ["$window"
  ($window) ->
    restrict: "A"
    link: (scope, element, attrs) ->
      element.bind "click", ->
        $window.history.back()
]
