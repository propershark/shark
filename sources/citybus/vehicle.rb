module CityBus
  class VehicleSource < Source
    ATTRIBUTES = [
      'name',
      'capacity',
      'onboard',
      'saturation',
      'heading',
      'speed'
    ]

    # This source requires extra parameters for creating associations between
    # Vehicles and their Routes/next Stations.
    def initialize key:, route_key:, station_key:
      super(key: key)
      @route_key    = route_key
      @station_key  = station_key
    end

    # Update the local cache of data to prepare for an `update` cycle
    def refresh
      @data = tripspark.vehicles.all.map do |vehicle|
        attrs = ATTRIBUTES.map{ |name| [name, vehicle.send(name)] }.to_h
        attrs['route']         = Shark::Route.identifier_for(vehicle.route.send(@route_key))
        attrs['next_station']  = Shark::Station.identifier_for(vehicle.next_stop.send(@station_key))
        [vehicle.send(@key), attrs]
      end.to_h
    end

    # Iterate through the local cache of data, activating and updating objects
    # on the given manager as they come up
    def update manager
      @data.each do |key, info|
        puts info
        # If the vehicle already exists in the manager, load it. Otherwise,
        # create a new one.
        vehicle = manager.find_or_new(key)
        # Update the information on the Vehicle object to match the current
        # data from the source
        vehicle.assign(info)
        # Ensure that the vehicle is active in the manager
        manager.activate(vehicle)
      end
    end
  end
end
