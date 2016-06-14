module DoubleMap
  class VehicleSource < Source
    # Update the local cache of data to prepare for an `update` cycle.
    def refresh
      @data = self.get.map do |vehicle|
        [vehicle[@key], vehicle]
      end.to_h
    end

    # Iterate through the local cache of data, activating objects on the
    # given manager as they come up.
    def update vehicle_manager
      @data.each do |key, vehicle|
        existing = vehicle_manager.get(key) || vehicle
        vehicle_manager.activate existing
      end
    end
  end
end
