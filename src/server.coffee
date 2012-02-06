#!/usr/bin/env coffee

config = require "../config/config.coffee"

creds = require "../config/creds.js"

request = require "request"
connect = require "connect"

passport = require "passport"
github = require "github"
meetup = require "meetup"


# one serializer for each service auth
#    (or let userid_from_profile handle each if they are similar)
# authenticate calls login which calls serializeUser
#    (or pass a callback to authenticate and do it manually)

userid_from_profile = (profile) ->
    # passport normalizes profiles to an extent and includes profile.provider
    # given profile and profile.provider
    # given our session cookie with userid
    #   add/confirm profile in userid object
    # given no session cookie
    #   look for matching profile 
    #   if found, make a session with existing userid 
    #   if not, make new userid
    #     now the user may have two userids
    
    userid    

passport.serializeUser (profile, done) ->
    # profile object from the service-specific auth scheme
    userid = userid_from_profile profile
    # userid goes to req._passport.session.user

    #console.log "serializeUser", profile, userid
    done null, userid

passport.deserializeUser (userid, done) ->
    # userid from req._passport.session.user
    user_session = session_data_from_userid userid
    # user_session goes to req.user
    # user_session contains access tokens for each service
    
    #console.log "deserializeUser", userid, user_session
    done null, user_session



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
    
    "/error": (req, res) ->
        res.redirect "/"

    "/logout": (req, res) ->
        req.logout()
        res.redirect "/"


_.extend routes, github.routes

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

# error handling based on NODE_ENV
app.use connect.errorHandler
    showStack: true
    dumpExceptions: true
    showMessage: true

app.use connect.cookieParser()
app.use connect.bodyParser()
app.use connect.query()
app.use connect.methodOverride()
app.use connect.session secret: creds.SESSION_SECRET
app.use passport.initialize()
app.use passport.session()

app.use quip()
app.use dispatch routes

app.use connect.favicon __dirname + '/public/favicon.ico' 
app.use connect.static __dirname + "/public"
#app.use connect.static config.STATICDIR

app.listen config.PORT

console.log config
console.log ?config.MSG | ""

