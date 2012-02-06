(function() {
  var account_template, app, authed_template, config, connect, creds, dispatch, github, meetup, oldroutes, page_template, passport, quip, request, routes, team_template, unauthed_template, userid_from_profile, _, _ref;
  config = require("../config/config.coffee");
  creds = require("../config/creds.js");
  request = require("request");
  connect = require("connect");
  passport = require("passport");
  github = require("github");
  meetup = require("meetup");
  userid_from_profile = function(profile) {
    return userid;
  };
  passport.serializeUser(function(profile, done) {
    var userid;
    userid = userid_from_profile(profile);
    return done(null, userid);
  });
  passport.deserializeUser(function(userid, done) {
    var user_session;
    user_session = session_data_from_userid(userid);
    return done(null, user_session);
  });
  _ = require('underscore');
  console.log(_.templateSettings);
  page_template = _.template("<!DOCTYPE html>\n<html>\n    <head><title>&nbsp;</title>\n        <style type=\"text/css\">\n            a:link {text-decoration: none}\n            a:visited {text-decoration: none}\n            a:active {text-decoration: none}\n            body {color: white; background-color: #999999; text-align:left;}\n            li {  list-style-type:none; }\n        </style>\n    </head>\n    <body'>\n        <%= text %>\n    </body>\n</html>");
  account_template = _.template("<p>ID: <%= user.id %></p>\n<p>Username: <%= user.username %></p>\n<p>Name: <%= user.displayName %></p>\n<p>Email: <%= user.emails[0].value %></p>");
  authed_template = _.template("<h2>Hello, <%= user.displayName %></h2>");
  unauthed_template = _.template("<a href=\"/auth/github\">Login with GitHub</a>");
  team_template = _.template("<ul> \n<% _.each(team, function(profile) { %>\n<li>\n<img src='<%= profile.avatar_url %>' height='30' width='30'> \n<a href='http://github.com/<%= profile.login %>'><%= profile.login %></a>\n</li> \n<% }); %> \n</ul>");
  routes = {
    "/": function(req, res) {
      if (req.user) {
        return res.html(page_template({
          text: authed_template({
            user: req.user
          })
        }));
      } else {
        return res.html(page_template({
          text: unauthed_template({})
        }));
      }
    },
    "/team": function(req, res) {
      return get_team(function(team) {
        return res.html(page_template({
          text: team_template(team)
        }));
      });
    },
    "/account": function(req, res, next) {
      if (!req.isAuthenticated()) {
        res.redirect("/login");
      }
      return res.html(page_template({
        text: account_template({
          user: req.user
        })
      }));
    },
    "/error": function(req, res) {
      return res.redirect("/");
    },
    "/logout": function(req, res) {
      req.logout();
      return res.redirect("/");
    }
  };
  _.extend(routes, github.routes);
  oldroutes = {
    '/about': function(req, res) {
      return res.text("hello");
    },
    '/atlantanodejs': function(req, res) {
      try {
        return res.html(template({
          text: 'hello world'
        }));
      } catch (error) {
        return res.notFound('Not found');
      }
    },
    '/api/(\\w+)': function(req, res, key) {
      try {
        return res.json(urlhash(key));
      } catch (error) {
        return res.notFound('Not found');
      }
    }
  };
  connect = require('connect');
  quip = require('quip');
  dispatch = require('dispatch');
  app = connect.createServer();
  app.use(connect.logger({
    format: ':method :url :response-time :res[Content-Type]'
  }));
  app.use(connect.cookieParser());
  app.use(connect.bodyParser());
  app.use(connect.query());
  app.use(connect.methodOverride());
  app.use(connect.session({
    secret: creds.SESSION_SECRET
  }));
  app.use(passport.initialize());
  app.use(passport.session());
  app.use(quip());
  app.use(dispatch(routes));
  app.use(connect.static(__dirname + "/public"));
  app.listen(config.PORT);
  console.log(config);
  ((_ref = console.log) != null ? _ref : config.MSG) | "";
}).call(this);
