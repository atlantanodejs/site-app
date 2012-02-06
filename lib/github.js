(function() {
  var GithubStrategy, creds, get_team, passport, usersample;
  passport = require("passport");
  GithubStrategy = require("passport-github").strategy;
  creds = require("../config/creds.js");
  passport.use(new GithubStrategy({
    clientid: creds.GITHUB_CLIENT_ID,
    clientsecret: creds.GITHUB_CLIENT_SECRET,
    callbackurl: config.baseurl + "auth/github/callback"
  }, function(accesstoken, refreshtoken, profile, done) {
    return process.nextTick(function() {
      console.log(accesstoken, refreshtoken, profile);
      return done(null, profile);
    });
  }));
  exports.routes = {
    "/auth/github": function(req, res, next) {
      var auth;
      auth = passport.authenticate("github", {
        scope: "user,public_repo"
      });
      return auth(req, res, next);
    },
    "/auth/github/callback": function(req, res, next) {
      var auth;
      console.log(req.query);
      auth = passport.authenticate("github", {
        failureRedirect: "/error",
        successRedirect: "/"
      });
      return auth(req, res, next);
    }
  };
  get_team = function(cb) {
    return request.get({
      headers: {
        Authorization: "token " + creds.ADMIN_TOKEN
      },
      url: "https://api.github.com/orgs/atlantanodejs/members",
      json: true
    }, function(error, response, body) {
      console.log(typeof body);
      console.log(error, body);
      console.log(team_template({
        team: body
      }));
      if (!error && response.statusCode === 200) {
        return cb({
          team: body
        });
      }
    });
  };
  usersample = {
    provider: 'github',
    id: 392395,
    displayName: 'Rick Thomas',
    username: 'irickt',
    profileUrl: 'https://github.com/irickt',
    emails: [
      {
        value: null
      }
    ]
  };
}).call(this);
