# A Middleware class for sending related events for each event that passes
# through it. For example, an `update` event on a Vehicle will cause a
# `vehicle_update` to go out on the Route that the vehicle is traveling.
class Conductor < Shark::Middleware
  class << self
    include Shark::Configurable
  end

  include Shark::Configurable
  inherit_configuration_from self

  def initialize app, *args
    super(app)
  end

  # Conductor is entirely implemented as event handlers, so no extra
  # processing is necessary here.
  def call event, channel, *args, **kwargs
    super
  end
end


# Include event-handling modules.
# This pattern allows these modules to access instance variables like `@app`
# and `@storage` without having to pass them around.
require_relative 'conductor/route_events'
require_relative 'conductor/station_events'
require_relative 'conductor/vehicle_events'
