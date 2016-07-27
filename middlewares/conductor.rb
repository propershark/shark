# A Middleware class for sending related events for each event that passes
# through it. For example, an `update` event on a Vehicle will cause a
# `vehicle_update` to go out on the Route that the vehicle is traveling.
class Conductor < Shark::Middleware
  class << self
    include Shark::Configurable
  end

  include Shark::Configurable
  inherit_configuration_from self

  # A map of event handlers indexed by namespace-topic pairs. New handlers can
  # be added through a call to `Conductor.register_handler`. The handler will
  # be called with the `app`, `channel`, `args`, and `kwargs` arguments.
  #
  # Any event that does not have a handler will use the default blank proc as
  # a handler (i.e., nothing will happen, but no error will occur).
  @@event_handlers = Hash.new{ |h, k| h[k] = Proc.new{} }
  def self.register_handler namespace, event, &handler
    @@event_handlers[[namespace, event]] = handler
  end

  def initialize app, *args
    super(app)
  end

  def call event, channel, *args, **kwargs
    # Instantiate and execute a handler for the event based on its namespace
    namespace, topic = channel.split('.')
    self.instance_exec(channel, args, kwargs, &@@event_handlers[[namespace, event]])

    # Pass through the event (with potentially modified arguments) to the next
    # middleware
    @app.call(event, channel, *args, kwargs)
  end
end


# Include event-handling modules.
# This pattern allows these modules to access instance variables like `@app`
# and `@storage` without having to pass them around.
require_relative 'conductor/route_events'
require_relative 'conductor/station_events'
require_relative 'conductor/vehicle_events'
