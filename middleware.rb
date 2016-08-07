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
    # A map of event handlers indexed by namespace-topic pairs. New handlers can
    # be added through a call to `Conductor.register_handler`. The handler will
    # be called with the `app`, `channel`, `args`, and `kwargs` arguments.
    #
    # Any event that does not have a handler will use the default blank proc as
    # a handler (i.e., nothing will happen, but no error will occur).
    def self.event_handlers
      @event_handlers ||= Hash.new{ |h, k| h[k] = Proc.new{} }
    end

    def self.register_handler namespace, event, &handler
      event_handlers[[namespace, event]] = handler
    end


    # Create a new instance of this middleware, including a reference to the
    # app that is stacked above it.
    def initialize app
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

    # Handle an event, potentially including some arguments
    def call event, channel, *args, **kwargs
      # Instantiate and execute a handler for the event based on its namespace.
      # Handlers are executed with the middleware instance as the receiver.
      namespace, topic = channel.split('.')
      self.instance_exec(channel, args, kwargs, &self.class.event_handlers[[namespace, event]])

      # Pass through the event (with potentially modified arguments) to the next
      # middleware
      @app.call(event, channel, *args, kwargs)
    end
  end
end
