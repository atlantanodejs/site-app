(function() {
  var MeetupStrategy, creds, passport;
  passport = require("passport");
  creds = require("../config/creds.js");
  MeetupStrategy = require("passport-meetup").strategy;
  passport.use(new MeetupStrategy({
    consumerkey: creds.MEETUP_CLIENT_ID,
    consumersecret: creds.MEETUP_CLIENT_SECRET,
    callbackurl: config.baseurl + "auth/meetup/callback"
  }, function(accesstoken, refreshtoken, profile, done) {
    return process.nextTick(function() {
      console.log(accesstoken, refreshtoken, profile);
      return done(null, profile);
    });
  }));
}).call(this);
