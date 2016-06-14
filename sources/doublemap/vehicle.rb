module DoubleMap
  class VehicleSource < Source
    def refresh
      @data = self.get.map do |vehicle|
        [vehicle[@key], vehicle]
      end.to_h
    end

    def update vehicle_manager
      @data.each do |key, vehicle|
        existing = vehicle_manager.get(key) || vehicle
        vehicle_manager.activate existing
      end
    end
  end
end
