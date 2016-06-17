module DoubleMap
  class VehicleSource < Source
    # A key-value map of attributes on the Vehicle class to entries in the
    # source data
    ATTRIBUTE_MAP = {
      code: 'name',
      name: 'name',
      latitude: 'lat',
      longitude: 'lon',
      heading: 'heading',
      route: 'route',
      last_stop: 'lastStop'
    }

    # Update the local cache of data to prepare for an `update` cycle
    def refresh
      @data = self.get.map do |vehicle|
        mapped_info = ATTRIBUTE_MAP.each_with_object({}) do |(prop, name), h|
          h[prop] = vehicle[name]
        end
        [vehicle[@key], mapped_info]
      end.to_h
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
