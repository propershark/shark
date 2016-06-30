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
  # Uses of Middleware include publishing over a network, logging, error
  # handling, or just extending the framework.
  class Middleware
    # Create a new instance of this middleware, including a reference to the
    # app that is stacked above it.
    def initialize app
      # If this is the top middleware (i.e., there are no middlewares stacked
      # above this one), `@app` will be a blank Proc since it responds to
      # `.call` and doesn't error with the wrong number of arguments.
      @app = app || Proc.new{}
    end

    # Return a truthy value when this middleware is fully initialized and ready
    # to accept events.
    def ready?
      true
    end

    # Handle an event, potentially including some arguments
    def call event, channel, *args
      raise "Middleware classes must override `call`"
    end
  end
end