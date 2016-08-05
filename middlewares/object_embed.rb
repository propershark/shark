# A Middleware class for replacing object identifiers with more detailed
# sets of attributes. For example, the `last_station` attribute of a vehicle
# (normally just an identifier), would get replaced with a hash with the keys
# `identifier` and `name`, so that clients can access the display name of the
# station with no extra effort
class ObjectEmbed < Shark::Middleware
  class << self
    include Shark::Configurable
  end

  include Shark::Configurable
  inherit_configuration_from self


  def initialize app, *args
    super(app)
  end

  def call event, channel, *args, **kwargs
    @app.call(event, channel, *args, kwargs)
  end
end
