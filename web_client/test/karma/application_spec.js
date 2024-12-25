//= require application
//= require angular-mocks

(function () {
  'use strict';
  angular.module('tv-dashboard').config(["$urlRouterProvider", function ($urlRouterProvider) {
    $urlRouterProvider.deferIntercept();
  }]);
}());
