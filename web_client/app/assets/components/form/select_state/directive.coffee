angular.module('tv-dashboard').directive 'selectState', [
  'States', 'lodash'
  (States, lodash) ->
    'use strict'
    scope:
      ngModel: '='
      country: '=selectStateCountry'
    link: (scope, element, attrs) ->
      scope.states = []

      scope.$watch 'country', (country) ->
        scope.states = []
        return unless country

        States.get country: country, (resource) ->
          scope.states = resource.states
          return
        return

      return
    template: '<select ng-model="ngModel" ng-options="state.id as state.name for state in states"></select>'
]
