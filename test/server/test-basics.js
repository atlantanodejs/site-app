(function() {
  var test, _;
  test = require("buster");
  _ = require('underscore');
  test.testCase("A module", {
    "states all obvious": function() {
      return assert(true);
    }
  });
}).call(this);
