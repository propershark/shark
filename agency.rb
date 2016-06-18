module Shark
  class Agency
    # The ObjectManager instances that cover all of the services provided by
    # this agency.
    # TODO: Expand to allow zero or multiple of each kind of manager, i.e.,
    # allow sharding of responsibility across multiple managers.
    attr_accessor :vehicle_manager
    attr_accessor :route_manager
    attr_accessor :station_manager
    # The Transport object through which all communications this agency makes
    # will take place
    attr_accessor :transport

    def initialize transport:
      @transport = transport
      @vehicle_manager = Shark::ObjectManager.new(
        event_handler: WebSocketEventHandler.new(namespace: 'vehicles', transport: @transport)
      )
      @route_manager = Shark::ObjectManager.new(
        event_handler: WebSocketEventHandler.new(namespace: 'routes', transport: @transport)
      )
      @station_manager = Shark::ObjectManager.new(
        event_handler: WebSocketEventHandler.new(namespace: 'stations', transport: @transport)
      )
    end
  end
end
