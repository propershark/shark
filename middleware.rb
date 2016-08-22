module Shark
  # Middlewares are classes that deal with events coming out of agencies. Each
  # agency will get it's own stack of Middleware instances, and when an event
  # is published, it will be propogated to each instance in the order they
  # were created (listed during configuration).
  #
  # Middleware is the layer between the agency and the outside world, acting
  # somewhat reverse to the middleware system in Rack. Where Rack middleware
  # is executed before an event reaches the application, here it is executed
  # when an event leaves the application.
  #
  # Uses of Middleware include publishing over a network, error handling,
  # creating new events, or simply extending the framework.
  class Middleware
    # Get or set the default event handler for this middleware. If `block` is
    # given, use it as the default event handler and return that proc. If
    # `block` is not given, simply return the current default proc.
    def self.default_event_handler &block
      if block_given?
        @default_event_handler = block
      else
        @default_event_handler ||= Proc.new{}
      end
    end

    # A map of event handlers indexed by namespace-topic pairs. New handlers
    # can be added through a call to `Middleware::register_handler`. The
    # handler will be called with the `channel`, `args`, and `kwargs`
    # arguments.
    #
    # Any event that does not have a handler will use the proc given by
    # `default_event_handler`. Unless explicitly set by a subclass, this
    # will be a blank proc.
    def self.event_handlers
      @event_handlers ||= Hash.new{ |h, k| h[k] = default_event_handler }
    end

    def self.register_handler namespace, event, &handler
      event_handlers[[namespace, event]] = handler
    end


    # Create a new instance of this middleware, including a reference to the
    # app that is stacked above it.
    def initialize app, *args
      # If this is the top middleware (i.e., there are no middlewares stacked
      # above this one), `@app` will be a blank Proc since it responds to
      # `.call` and doesn't error with the wrong number of arguments.
      @app = app || Proc.new{}
      # Provide instance-level access to the storage adapter being used by
      # the main app.
      @storage = Storage.adapter
    end

    # Return a truthy value when this middleware is fully initialized and ready
    # to accept events.
    def ready?
      true
    end

    # Return the event handler proc for the given namespace and event type.
    def handler_for namespace, event_type
      self.class.event_handlers[[namespace, event_type]]
    end

    # Handle an event, potentially including some arguments
    def call event
      # Instantiate and execute a handler for the event based on its namespace.
      # Handlers are executed with the middleware instance as the receiver.
      namespace, topic = event.topic.split('.')
      self.instance_exec(event, &handler_for(namespace, event.type))

      # Pass through the event (with potentially modified arguments) to the next
      # middleware
      fire(event)
    end


    # Wrapper for `@app.call(<event>)` to proxy an event up the middleware
    # stack in a more native way (purely aesthetic).
    def fire event
      @app.call(event)
    end


    # Attempt to resolve the given argument to an Object instance, either
    # directly, or by attempting a lookup on `@storage`.
    #
    # If an instance can not be found, return nil.
    def resolve_object obj
      case obj
      when Shark::Object
        obj
      when String
        obj.identifier? ? @storage.find(obj) : nil
      else
        nil
      end
    end
  end
end
