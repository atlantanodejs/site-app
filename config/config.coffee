_ = require 'underscore'
#_.templateSettings = { interpolate : /\{\{(.+?)\}\}/g }
package = require "../package" 

config =
    TITLE: package.name
    DESCRIPTION: package.description
    VERSION: package.version

config_dev =
    PORT: 3000
    HOST: "local.host"
    STATICDIR: "Users/rick/_engine/"

config_live =
    PORT: 80
    HOST: "sevaa.atlantanodejs.org"
    STATICDIR: "/home/irickt/live/sevaa.atlantanodjs.org/public"

# use ENV
_.extend config, config_live # config_dev # 

str = "http://<%=HOST%>:<%=PORT%>/"
_.extend config, {BASEURL: _.template str, config }

str = "<%=TITLE%> listening on <%=BASEURL%> serving from <%=STATICDIR%>"
_.extend config, {MSG: _.template str, config}

module.exports = config


