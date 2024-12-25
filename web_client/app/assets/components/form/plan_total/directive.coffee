angular.module('tv-dashboard').directive 'planTotal', [
  'lodash'
  (lodash) ->
    'use strict'
    restrict: 'E'
    require: 'ngModel'
    scope:
      plan: '=ngModel'
      title: '@planTotalTitle'

    link: (scope, element, attrs, ctrl) ->
      scope.isFree = (plan) ->
        return unless plan
        plan.cost == '0.00'
      return

    templateUrl: 'form/plan_total.html'
]
