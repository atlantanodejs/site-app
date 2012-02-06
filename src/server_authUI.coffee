#!/usr/bin/env coffee

config = require "../config/config.coffee"

_ = require 'underscore'

#process.on "uncaughtException", (err) ->
#    console.log "Caught exception: " + err


# represents all the available services and user status with each service
class Services
    initialize: ->
    
    loadFromSession: ->
        # currently in memory
    
    saveToSession: (service) ->
        # done during auth
    
    
    
class AuthUI
    constructor: (j) ->
        this.routes['/refresh'] = _.bind this.routes['/refresh'], this
        this.routes['/services'] = _.bind this.routes['/services'], this
        this.routes['/auth/:name'] = _.bind this.routes['/auth/:name'], this
        this.routes['/unauth/:name'] = _.bind this.routes['/unauth/:name'], this
        
        # => only binds direct member functions
        # _.bindAll this.routes binds all to this.routes
        # so bind each to this
        #
        #but something is wrong with the obvious iteration using _.each
        #obj = {}
        #_.each this.routes, (v, k, t) -> 
        #    obj[k] = _.bind v, this
        #this.routes = obj
        

    services: [
        {name: "github", label: "Github"}
        {name: "meetup", label: "Meetup"}
        {name: "twitter", label: "Twitter"}
        ]
        
    # might be async later so use callback
    findServiceByName: (name, cb) ->
        service = _.find this.services, (service) -> service.name is name 
        if service then cb(null, service) else cb("Service '#{name}' not found", null) # todo error object
    
    unauth: (name, cb) ->
        @findServiceByName name, (err, index) ->
            return cb(err, null) if err
            console.log "unauth", name, index
            #service.unauth(index)
            cb null, {message: "ok"}
    
    auth: (name, cb) ->
        @findServiceByName name, (err, index) ->
            return cb(err, null) if err
            console.log "auth", name, index
            #service.auth(index)
            cb null, {message: "ok"}

        
    # res.headers(this.headers).json{} # content-type is implied
    headers:
        'Content-Type': 'text/javascript'
    
    routes:
        '/refresh': (req, res) ->
            console.log '/services', this.services
            res.json this.services
        
        '/services': (req, res) ->
            console.log '/services', this.services
            res.json this.services
        
        '/auth/:name': (req, res, next, name) ->
            this.auth name, (err, results) ->
                if err
                    res.notFound().json {status: 'error', details: err}
                else
                    res.json {status: 'success', details: results} 
        
        '/unauth/:name': (req, res, next, name) ->
            this.unauth name, (err, results) ->
                if err
                    res.notFound().json {status: 'error', details: err}
                else
                    res.json {status: 'success', details: results}


exports = new AuthUI(1)


return unless require.main is module # then start a test server

authUI = exports
routes = authUI.routes
console.log "authUI.services", authUI.services
console.log "authUI.routes", authUI.routes

connect = require 'connect'
quip = require 'quip'
dispatch = require 'dispatch'

app = connect.createServer()

app.use connect.logger { format: ':method :url :response-time :res[Content-Type]' }
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
app.use connect.session secret: "opensecret" #creds.SESSION_SECRET
#app.use passport.initialize()
#app.use passport.session()

app.use quip()
app.use dispatch routes

app.use connect.favicon '../public/favicon.ico' # in config
app.use connect.static "../public"
#app.use connect.static config.STATICDIR

app.listen config.PORT

console.log config
console.log ?config.MSG | ""
