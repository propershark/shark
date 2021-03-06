module TripSparkSource
  class VehicleSource < Source
    def refresh
      api.flush_cache
      # For each vehicle, create a hash of the values of each attribute and add
      # that hash to the data hash, indexed by the primary key specified in
      # the configuration of this Source.
      @data = api.vehicles.all.map do |vehicle|
        attrs = @vehicle_attributes.map{ |prop, name| [prop, vehicle.send(name)] }.to_h
        route_key   = @route_key.call(vehicle.route) rescue nil
        station_key = @station_key.call(vehicle.next_stop) rescue nil
        attrs[:route]         = Shark::Route.identifier_for(route_key)
        attrs[:next_station]  = Shark::Station.identifier_for(station_key)
        ["vehicles."+@vehicle_key.call(vehicle), attrs]
      end.to_h
    end
  end

  register_source :tripspark, Shark::Vehicle, VehicleSource
end
