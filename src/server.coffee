#!/usr/bin/env coffee

config = require "../config/config.coffee"

creds = require "../config/creds.js"

request = require "request"
connect = require "connect"
passport = require "passport"
GitHubStrategy = require("passport-github").Strategy

passport.use new GitHubStrategy 
    clientID: creds.GITHUB_CLIENT_ID
    clientSecret: creds.GITHUB_CLIENT_SECRET
    callbackURL: config.BASEURL + "auth/github/callback"
    ,
    (accessToken, refreshToken, profile, done) ->
        process.nextTick ->
            console.log accessToken, refreshToken, profile
            done null, profile

# sample user data from github
usersample =
    provider: 'github'
    id: 392395
    displayName: 'Rick Thomas'
    username: 'irickt'
    profileUrl: 'https://github.com/irickt'
    emails: [ { value: null } ] 

passport.serializeUser (user, done) ->
    #console.log "serializeUser", user
    done null, user

passport.deserializeUser (obj, done) ->
    #console.log "deserializeUser", obj
    done null, obj



#path = require "path"
#fs = require "fs"

    

_ = require 'underscore'
console.log _.templateSettings

page_template = _.template """
    <!DOCTYPE html>
    <html>
        <head><title>&nbsp;</title>
            <style type="text/css">
                a:link {text-decoration: none}
                a:visited {text-decoration: none}
                a:active {text-decoration: none}
                body {color: white; background-color: #999999; text-align:left;}
                li {  list-style-type:none; }
            </style>
        </head>
        <body'>
            <%= text %>
        </body>
    </html>
"""
account_template = _.template """
    <p>ID: <%= user.id %></p>
    <p>Username: <%= user.username %></p>
    <p>Name: <%= user.displayName %></p>
    <p>Email: <%= user.emails[0].value %></p>
"""
authed_template = _.template """
    <h2>Hello, <%= user.displayName %></h2>
"""
unauthed_template = _.template """
    <a href="/auth/github">Login with GitHub</a>
"""
team_template = _.template """
    <ul> 
    <% _.each(team, function(profile) { %>
    <li>
    <img src='<%= profile.avatar_url %>' height='30' width='30'> 
    <a href='http://github.com/<%= profile.login %>'><%= profile.login %></a>
    </li> 
    <% }); %> 
    </ul>
"""

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

routes =
    "/": (req, res) ->
        if req.user
            res.html page_template
                text: authed_template
                    user: req.user
        else
            res.html page_template
                text: unauthed_template {}
    
    "/team": (req, res) ->
        get_team (team) ->
            res.html page_template
                text: team_template team
            
    "/account": (req, res, next) ->
        if !req.isAuthenticated()
            res.redirect "/login"
        res.html page_template
            text: account_template
                user: req.user
    
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

    "/error": (req, res) ->
        res.redirect "/"

    "/logout": (req, res) ->
        req.logout()
        res.redirect "/"

oldroutes = 
    '/about': (req, res) ->
        res.text "hello"
    '/atlantanodejs': (req, res) ->
        try
            res.html template 
                text: 'hello world'
        catch error
            res.notFound('Not found')
    '/api/(\\w+)': (req, res, key) ->
        try
            res.json urlhash key
        catch error
            # res.json({})
            res.notFound('Not found')



connect = require 'connect'
quip = require 'quip'
dispatch = require 'dispatch'

app = connect.createServer()

app.use connect.logger {format: ':method :url :response-time :res[Content-Type]' }
# app.use connect.logger "short"
#app.use connect.logger {format: ':url :remote-addr :referrer :req'}
#app.use connect.dump()

app.use connect.cookieParser()
app.use connect.bodyParser()
app.use connect.query()
app.use connect.methodOverride()
app.use connect.session secret: creds.SESSION_SECRET
app.use passport.initialize()
app.use passport.session()

app.use quip()
app.use dispatch routes

app.use connect.static __dirname + "/public"
#app.use connect.static config.STATICDIR

app.listen config.PORT

console.log config
console.log ?config.MSG | ""

