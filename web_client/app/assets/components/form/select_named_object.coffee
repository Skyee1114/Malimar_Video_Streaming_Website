angular.module('tv-dashboard').directive "selectNamedObject", ->
  scope:
    ngModel: '='
    source: '='
  template: '<select ng-model="ngModel" ng-options="o as o.name for o in source"></select>'
