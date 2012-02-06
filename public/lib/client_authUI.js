(function() {
  var AppView, Service, ServiceList, ServiceListView, ServiceView,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Service = (function(_super) {
    var state;

    __extends(Service, _super);

    function Service() {
      Service.__super__.constructor.apply(this, arguments);
    }

    Service.prototype.initialize = function(name) {
      this.name = name;
    };

    Service.prototype.defaults = state = "";

    Service.prototype.auth = function(cb) {
      return $.ajax({
        url: "/auth/" + this.get("name"),
        success: function(data) {
          this.state = "auth";
          console.log("ajax response", data);
          return cb(data);
        },
        error: function(jqXHR, textStatus, errorThrown) {
          return $('body').append("AJAX Error: ${textStatus}.");
        }
      });
    };

    Service.prototype.unauth = function(cb) {
      return $.ajax({
        url: "/unauth/" + this.get("name"),
        success: function(data) {
          this.state = "unauth";
          console.log("ajax response", data);
          return cb(data);
        },
        error: function(jqXHR, textStatus, errorThrown) {
          return $('body').append("AJAX Error: ${textStatus}.");
        }
      });
    };

    return Service;

  })(Backbone.Model);

  ServiceList = (function(_super) {

    __extends(ServiceList, _super);

    function ServiceList() {
      ServiceList.__super__.constructor.apply(this, arguments);
    }

    ServiceList.prototype.model = Service;

    ServiceList.prototype.url = "/services";

    ServiceList.prototype.comparator = function(service) {
      return service.get("name");
    };

    ServiceList.prototype.getByName = function(name) {
      return this.find(function(service) {
        return service.get("name") === name;
      });
    };

    return ServiceList;

  })(Backbone.Collection);

  ServiceView = (function(_super) {

    __extends(ServiceView, _super);

    function ServiceView() {
      this.remove = __bind(this.remove, this);
      this.unauth = __bind(this.unauth, this);
      this.auth = __bind(this.auth, this);
      this.render = __bind(this.render, this);
      this.initialize = __bind(this.initialize, this);
      ServiceView.__super__.constructor.apply(this, arguments);
    }

    ServiceView.prototype.tagName = "div";

    ServiceView.prototype.className = "row";

    ServiceView.prototype.template = _.template($("#service-tmpl").html());

    ServiceView.prototype.events = {
      "click .auth": "auth",
      "click .unauth": "unauth"
    };

    ServiceView.prototype.initialize = function(model) {
      this.model = model;
      return this.model.on("destroy", this.remove, this);
    };

    ServiceView.prototype.render = function() {
      console.log("render", this.model.toJSON());
      $(this.el).html(this.template(this.model.toJSON()));
      return this;
    };

    ServiceView.prototype.auth = function(e) {
      var $row;
      if (e) e.preventDefault();
      $row = $(this.el);
      $row.addClass("load");
      return this.model.auth(function(result) {
        console.log("result", result);
        return $row.removeClass("load");
      });
    };

    ServiceView.prototype.unauth = function(e) {
      var $row;
      if (e) e.preventDefault();
      $row = $(this.el);
      $row.addClass("load");
      return this.model.unauth(function(result) {
        console.log("result", result);
        return $row.removeClass("load");
      });
    };

    ServiceView.prototype.remove = function() {
      return $(this.el).remove();
    };

    return ServiceView;

  })(Backbone.View);

  ServiceListView = (function(_super) {

    __extends(ServiceListView, _super);

    function ServiceListView() {
      ServiceListView.__super__.constructor.apply(this, arguments);
    }

    ServiceListView.prototype.el = $("#service-list");

    ServiceListView.prototype.initialize = function() {
      this.Services = new ServiceList();
      this.Services.fetch();
      return this.Services.on("all", this.update, this);
    };

    ServiceListView.prototype.update = function() {
      var _this = this;
      this.$el.empty();
      this.Services.each(function(service) {
        var view;
        console.log(service);
        view = new ServiceView(service);
        return _this.$el.append(view.render().el);
      });
      return this.render();
    };

    return ServiceListView;

  })(Backbone.View);

  AppView = (function(_super) {

    __extends(AppView, _super);

    function AppView() {
      AppView.__super__.constructor.apply(this, arguments);
    }

    AppView.prototype.el = $(".container");

    AppView.prototype.initialize = function(serviceData) {
      this.$("#app-version").text("0.0.1");
      this.serviceListView = new ServiceListView;
      return this.render();
    };

    AppView.prototype.render = function() {
      this.serviceListView.render();
      return this;
    };

    return AppView;

  })(Backbone.View);

  $(function() {
    var app_view;
    console.log("loading");
    return app_view = new AppView;
  });

}).call(this);
