angular.module('tv-dashboard').directive 'browserUpdate', [
  '$window', 'angularLoad'
  ($window, angularLoad) ->
    'use strict'
    restrict: 'E'
    link: (scope, element, attrs) ->
      $window.$buoop =
        vs: {c:2}
        reminder: 10
        reminderClosed: 24
        newwindow: true

      angularLoad.loadScript("//browser-update.org/update.min.js")
      return
]
