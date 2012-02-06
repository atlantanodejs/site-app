passport = require "passport"
GithubStrategy = require("passport-github").strategy
creds = require "../config/creds.js"

passport.use new GithubStrategy
    clientid: creds.GITHUB_CLIENT_ID
    clientsecret: creds.GITHUB_CLIENT_SECRET
    callbackurl: config.baseurl + "auth/github/callback"
    ,
    (accesstoken, refreshtoken, profile, done) ->
        process.nextTick ->
            console.log accesstoken, refreshtoken, profile
            done null, profile

exports.routes =
    "/auth/github": (req, res, next) ->
        auth = passport.authenticate "github",
            scope: "user,public_repo"
        auth req, res, next
        
    "/auth/github/callback": (req, res, next) ->
        console.log req.query
        auth = passport.authenticate "github",
            failureRedirect: "/error"
            successRedirect: "/"
        auth req, res, next

get_team = (cb) ->
    request.get
        headers:
            Authorization: "token " + creds.ADMIN_TOKEN
        url: "https://api.github.com/orgs/atlantanodejs/members"
        json: true
        ,
        (error, response, body) ->
            console.log typeof body
            #body = team: JSON.parse body
            console.log error, body
            console.log team_template team: body
            if  !error && response.statusCode == 200
                cb team: body


# sample user data from passport-github
usersample =
    provider: 'github'
    id: 392395
    displayName: 'Rick Thomas'
    username: 'irickt'
    profileUrl: 'https://github.com/irickt'
    emails: [ { value: null } ] 
