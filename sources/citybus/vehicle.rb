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

    # Update the local cache of data to prepare for an `update` cycle
    def refresh
      @data = tripspark.vehicles.all.map do |vehicle|
        [vehicle.send(@key), ATTRIBUTES.map{ |name| [name, vehicle.send(name)] }.to_h]
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
