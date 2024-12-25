require('coffee-script')
var mockModule = require('./mock-backend');

exports.config = {
  seleniumAddress: 'http://localhost:4444/wd/hub',

  capabilities: {
    'browserName': 'chrome'
  },

  specs: [
    '../e2e/*_scenario.coffee'
  ],

  baseUrl: 'http://localhost:3000',

  framework: "jasmine",

  jasmineNodeOpts: {
    onComplete: null,
    isVerbose: false,
    showColors: true,
    includeStackTrace: true,
    defaultTimeoutInterval: 30000
  },

  onPrepare: function() {
    browser.addMockModule('httpBackendMock', mockModule.httpBackendMock);
  }
};
