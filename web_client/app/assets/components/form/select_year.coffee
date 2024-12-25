angular.module('tv-dashboard').directive "selectYear", ->
  currentYear = (new Date).getFullYear()
  scope:
    ngModel: '='
  link: (scope, element, attrs) ->
    scope.years = []
    limit     = +attrs.limit
    offset    = +attrs.offset || 0
    startYear = currentYear + offset

    scope.years.push(startYear + i) for i in [0 ... limit]
    return
  template: '<select ng-model="ngModel" ng-options="y for y in years"></select>'
