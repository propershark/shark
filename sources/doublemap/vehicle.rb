module DoubleMapSource
  class VehicleSource < Source
    def refresh
      api.flush_cache
      # For each vehicle, create a hash of the values of each attribute and add
      # that hash to the data hash, indexed by the primary key specified in
      # the configuration of this Source.
      @data = api.vehicles.all.select{ |v| check_valid v }.map do |vehicle|
        attrs = @vehicle_attributes.map{ |prop, name| [prop, vehicle.send(name)] }.to_h
        route_key   = @route_key.call(api.routes.get(vehicle.route)) rescue nil
        station_key = @station_key.call(api.stops.get(vehicle.last_stop)) rescue nil
        attrs[:route]         = Shark::Route.identifier_for(route_key) rescue nil
        attrs[:last_station]  = Shark::Station.identifier_for(station_key) rescue nil
        ["vehicles."+@vehicle_key.call(vehicle), attrs]
      end.to_h
    end

    def valid?(vehicle)
      @vehicle_key.call(vehicle) and
        @vehicle_attributes.values.all? { |v| vehicle.respond_to? v } 
    end
  end

  register_source :doublemap, Shark::Vehicle, VehicleSource
end
