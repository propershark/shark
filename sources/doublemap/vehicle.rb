module DoubleMap
  class VehicleSource < Source
    # A key-value map of attributes on the Vehicle class to entries in the
    # source data
    ATTRIBUTES = [
      'name',
      'lat',
      'lon'
    ]

    # This source requires extra parameters for creating associations between
    # Vehicles and their Routes/next Stations.
    def initialize agency:, key:, route_key:, station_key:
      super(agency: agency, key: key)
      @route_key    = route_key
      @station_key  = station_key
    end

    # Update the local cache of data to prepare for an `update` cycle
    def refresh
      # For each vehicle, create a hash of the values of each attribute and add
      # that hash to the data hash, indexed by the primary key specified in
      # the configuration of this Source.
      @data = doublemap.vehicles.all.map do |vehicle|
        attrs = ATTRIBUTES.map{ |name| [name, vehicle.send(name)] }.to_h
        route_key   = doublemap.routes.get(vehicle.route).send(@route_key)
        station_key = doublemap.stops.get(vehicle.last_stop).send(@station_key)
        attrs['route']         = Shark::Route.identifier_for(route_key)
        attrs['last_station']  = Shark::Station.identifier_for(station_key)
        [vehicle.send(@key), attrs]
      end.to_h
    end

    # Iterate through the local cache of data, activating and updating objects
    # on the given manager as they come up
    def update manager
      @data.each do |key, info|
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
