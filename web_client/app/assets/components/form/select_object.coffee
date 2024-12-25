angular.module('tv-dashboard').directive "selectObject", ->
  scope:
    ngModel: '='
    source: '='
  template: '<select ng-model="ngModel" ng-options="o for o in source"></select>'
