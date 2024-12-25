angular.module('tv-dashboard').directive "selectMonth", ->
  scope:
    ngModel: '='
  link: (scope, element, attrs) ->
    month_names = [ "Jan", "Feb", "Mar", "Apr", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec" ]
    scope.monthes = []
    for i in [1 .. 12]
      scope.monthes.push(
        label: "#{ if i < 10 then 0 else '' }#{ i } - #{ month_names[i - 1] }"
        value: i
      )
    return
  template: '<select ng-model="ngModel" ng-options="month.value as month.label for month in monthes"></select>'
