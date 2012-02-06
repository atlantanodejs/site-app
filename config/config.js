(function() {
  var config, config_dev, config_live, package, str, _;

  _ = require('underscore');

  package = require("../package");

  config = {
    TITLE: package.name,
    DESCRIPTION: package.description,
    VERSION: package.version
  };

  config_dev = {
    PORT: 3000,
    HOST: "local.host",
    STATICDIR: "Users/rick/_engine/"
  };

  config_live = {
    PORT: 80,
    HOST: "sevaa.atlantanodejs.org",
    STATICDIR: "./public"
  };

  _.extend(config, config_live);

  str = "http://<%=HOST%>:<%=PORT%>/";

  _.extend(config, {
    BASEURL: _.template(str, config)
  });

  str = "<%=TITLE%> listening on <%=BASEURL%> serving from <%=STATICDIR%>";

  _.extend(config, {
    MSG: _.template(str, config)
  });

  module.exports = config;

}).call(this);
