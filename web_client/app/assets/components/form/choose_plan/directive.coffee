angular.module('tv-dashboard').directive 'choosePlan', [
  '$state', '$rootScope', 'lodash'
  ($state, $root, lodash) ->
    'use strict'
    restrict: 'E'
    require: 'ngModel'
    scope:
      plan: '=ngModel'
      plan_collection: '=plans'
      title: '@choosePlanTitle'
      default_price: '@choosePlanDefaultPrice'

    link: (scope, element, attrs, ctrl) ->
      scope.selectPlan = (available_plan) ->
        ctrl.$setViewValue(available_plan)

      scope.choosePlan = (available_plan) ->
        scope.selectPlan available_plan
        $root.plan = available_plan

      scope.isSelected = (available_plan) ->
        return unless available_plan
        available_plan == scope.plan

      scope.features = (available_plan) ->
        features = []
        features.push "TV" if available_plan.includes_roku_content
        features.push "Website" if available_plan.includes_web_content
        features.join ' + '

      defaultPlan = (collection) ->
        plan = lodash.find collection, $root.plan
        plan_sorter = (plan) -> parseFloat(plan.cost)

        plan ||= if scope.default_price == 'min'
          lodash.min collection, plan_sorter
        else
          lodash.max collection, plan_sorter

      unWatchCollection = scope.$watch 'plan_collection', (collection) ->
        return unless collection && collection.length > 0

        scope.plans = collection
        scope.selectPlan defaultPlan(scope.plans)

        unWatchCollection()
        return
      return
    templateUrl: 'form/choose_plan.html'
]
