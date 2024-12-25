module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-protractor-runner'
  grunt.loadNpmTasks 'grunt-protractor-webdriver'

  grunt.initConfig
    protractor:
      options:
        keepAlive: true
        noColor: false
      coffee:
        configFile: 'test/protractor/conf.js'
      all: {}
    protractor_webdriver:
      options: {}
      all: {}

  grunt.registerTask 'e2e', [
    'protractor_webdriver'
    'protractor:coffee'
  ]
  return
