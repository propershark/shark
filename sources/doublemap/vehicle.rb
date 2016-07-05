module DoubleMapSource
  class VehicleSource < Source
    def refresh
      # For each vehicle, create a hash of the values of each attribute and add
      # that hash to the data hash, indexed by the primary key specified in
      # the configuration of this Source.
      @data = api.vehicles.all.map do |vehicle|
        attrs = ATTRIBUTES.map{ |prop, name| [prop, vehicle.send(name)] }.to_h
        route_key   = @route_key.call(api.routes.get(vehicle.route))
        station_key = @station_key.call(api.stops.get(vehicle.last_stop))
        attrs[:route]         = Shark::Route.identifier_for(route_key)
        attrs[:last_station]  = Shark::Station.identifier_for(station_key)
        [@vehicle_key.call(vehicle), attrs]
      end.to_h
    end
  end

  register_source :doublemap, Shark::Vehicle, VehicleSource
end
