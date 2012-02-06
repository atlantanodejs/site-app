(function() {
  module.exports = {
    "browser tests": {
      environment: "browser",
      sources: ["../public/js/index.js"],
      tests: ["./browser/test-*.js"]
    },
    "server tests": {
      environment: "node",
      tests: ["./server/test-*.js"]
    }
  };
}).call(this);
