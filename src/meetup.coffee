passport = require "passport"
creds = require "../config/creds.js"

MeetupStrategy = require("passport-meetup").strategy

passport.use new MeetupStrategy 
    consumerkey: creds.MEETUP_CLIENT_ID
    consumersecret: creds.MEETUP_CLIENT_SECRET
    callbackurl: config.baseurl + "auth/meetup/callback"
    ,
    (accesstoken, refreshtoken, profile, done) ->
        process.nextTick ->
            console.log accesstoken, refreshtoken, profile
            done null, profile

# https://api.meetup.com/2/members.json/?group_id=2792482&access_token=85f9...
# https://api.meetup.com/2/groups.json/?group_id=2792482&access_token=85f9...