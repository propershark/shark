# A Middleware class for replacing object identifiers with more detailed
# sets of attributes. For example, the `last_station` attribute of a vehicle
# (normally just an identifier), would get replaced with a hash with the keys
# `identifier` and `name`, so that clients can access the display name of the
# station with no extra effort
class Serializer < Shark::Middleware
  class << self
    include Shark::Configurable
  end

  include Shark::Configurable
  inherit_configuration_from self


  # Since Object embedding is currently agnostic of the event that the object
  # is contained by, it can always be done using the same block. So, set that
  # block as the default event handler, so that all events are automatically
  # handled, without concern over new or deprecated events.
  #
  # All Object arguments that embed information will be converted to Hashes by
  # this event handler,
  default_event_handler do |channel, args, kwargs|
    args.map! do |arg|
      case arg
      # Routes embed their associated stations.
      when Shark::Route
        arg
      # Vehicles embed their last and next stations, and a simplified version
      # of the route they are traveling.
      when Shark::Vehicle
        arg
      # Stations do not currently embed any information
      when Shark::Station
        arg
      # All Object instances should be converted to hashes (regardless of
      # whether they embedded information) for consistency.
      when Shark::Object
        arg.to_h
      else
        arg
      end
    end
  end


  def initialize app, *args
    super(app)
  end

  def call event, channel, *args, **kwargs
    @app.call(event, channel, *args, kwargs)
  end
end
