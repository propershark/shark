module CityBus
  class VehicleSource < Source
    # A key-value map of attributes on the Vehicle class to entries in the
    # source data
    ATTRIBUTE_MAP = {
      name: 'Name',
      capacity: 'PassengerCapacity',
      passengers: 'PassengersOnboard',
      saturation: 'PercentFilled'
    }

    # Update the local cache of data to prepare for an `update` cycle
    def refresh
      # The CityBus API requires route-direction pairs as parameters to
      # return any vehicle information. RouteSource caches this information
      # specifically for this purpose.
      params = RouteSource.route_direction_pairs.map do |(route, direction)|
        { RouteKey: route, DirectionKey: direction }
      end
      formatted_params = params.each.with_index.with_object('routeDirectionKeys').map do |(p, i), s|
        "#{s}[#{i}][RouteKey]=#{p[:RouteKey]}&#{s}[#{i}][DirectionKey]=#{p[:DirectionKey]}"
      end.join('&')
      # Execute a request for all vehicles travelling the known routes.
      raw_data = self.post(formatted_params)
      @data = raw_data.each_with_object({}) do |rd_entry, data|
        # Vehicle entries are keyed as arrays of vehicles under patterns.
        rd_entry['VehiclesByPattern'].each do |vehicles_for_pattern|
          vehicles_for_pattern['Vehicles'].each do |vehicle|
            mapped_info = ATTRIBUTE_MAP.each_with_object({}) do |(prop, name), h|
              h[prop] = vehicle[name]
            end
            # The heading and speed of the vehicle are hidden in the GPS field,
            # so they must be extracted manually.
            mapped_info[:speed] = vehicle['GPS']['Spd']
            mapped_info[:heading] = vehicle['GPS']['Dir']
            # After all attributes have been mapped, the vehicle can be added
            # to the data hash
            data[mapped_info[@key]] = mapped_info
          end
        end
      end
    end

    # Iterate through the local cache of data, activating and updating objects
    # on the given manager as they come up
    def update manager
      @data.each do |key, info|
        # If the vehicle already exists in the manager, load it. Otherwise,
        # create a new one.
        vehicle = manager.get(key) || ::Shark::Vehicle.new
        # Update the information on the Vehicle object to match the current
        # data from the source
        vehicle.assign(info)
        # Ensure that the vehicle is active in the manager
        manager.activate(vehicle)
      end
    end
  end
end
