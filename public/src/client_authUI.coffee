
class Service extends Backbone.Model
    initialize: (@name) ->
    
    defaults:
        # label = _.str.capitalize this.name
        # https://github.com/epeli/underscore.string
        state = ""
    
    auth: (cb) ->
        $.ajax
            url: "/auth/" + this.get "name"
            success: (data) ->
                this.state = "auth"
                console.log "ajax response", data
                cb data #data.details.message
            error: (jqXHR, textStatus, errorThrown) -> 
                $('body').append "AJAX Error: ${textStatus}." # debug
	        
    unauth: (cb) ->
        $.ajax
            url: "/unauth/" + this.get "name"
            success: (data) ->
                this.state = "unauth"
                console.log "ajax response", data
                cb data
            error: (jqXHR, textStatus, errorThrown) -> 
                $('body').append "AJAX Error: ${textStatus}." # debug
        
# http://coffeescriptcookbook.com/chapters/jquery/ajax
# http://api.jquery.com/jQuery.ajax/	
	
	
class ServiceList extends Backbone.Collection
    model: Service
    url: "/services"
    comparator: (service) ->
        service.get "name"

    getByName: (name) ->
        this.find (service) ->
            service.get("name") is name


class ServiceView extends Backbone.View
    tagName: "div"
    className: "row"
    template: _.template $("#service-tmpl").html()
    events:
        "click .auth": "auth"
        "click .unauth": "unauth"

    initialize: (@model) =>
        #_.bindAll this # fat arrow does it
        this.model.on "destroy", this.remove, this

    render: =>
        console.log "render", this.model.toJSON()
        $(this.el).html this.template this.model.toJSON() 
        this

    auth: (e) =>
        e.preventDefault() if e
        $row = $(this.el)
        $row.addClass "load"
        this.model.auth (result) ->
            console.log "result", result
            $row.removeClass "load"
            #_.delay this.model.collection.fetch(), 1000

    unauth: (e) =>
        e.preventDefault() if e
        $row = $(this.el)
        $row.addClass "load"
        this.model.unauth (result) ->
            console.log "result", result
            $row.removeClass "load"
            #_.delay this.model.collection.fetch(), 1000

    remove: =>
        $(this.el).remove()
        

class ServiceListView extends Backbone.View
    el: $ "#service-list"
    
    initialize: () ->        
        this.Services = new ServiceList()
        this.Services.fetch()
        #this.Services.reset serviceData
        
        this.Services.on "all", this.update, this
        #this.update()
    
    update: ->
        this.$el.empty()
        this.Services.each (service) =>
            console.log service
            view = new ServiceView service
            this.$el.append view.render().el
        this.render()


class AppView extends Backbone.View
    el: $ ".container"
    #events:
    #    "click .refresh": "refresh"

    initialize: (serviceData) ->
        this.$("#app-version").text "0.0.1" # todo use config
        
        this.serviceListView = new ServiceListView
        this.render()

    render: ->
        #this.$("#service-count").text this.Services.length
        this.serviceListView.render()
        this


$ ->
    console.log "loading"
    app_view = new AppView 
