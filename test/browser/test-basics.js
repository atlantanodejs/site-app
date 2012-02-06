(function() {
  var test;
  test = window.buster;
  test.testCase("A module", {
    "states browser obvious": function() {
      return assert(true);
    }
  });
}).call(this);
