angular.module('tv-dashboard').filter 'trust_html', [
  '$sce'
  ($sce) ->
    'use strict'
    (htmlCode) ->
      $sce.trustAsHtml htmlCode
]
