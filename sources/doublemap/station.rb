module DoubleMap
  class StationSource < Source
    # A key-value map of attributes on the Station class to entries in the
    # source data
    ATTRIBUTE_MAP = {
      code: 'id',
      name: 'name',
      stop_code: 'stop_code',
      description: 'description',
      latitude: 'lat',
      longitude: 'lon'
    }

    # Update the local cache of data to prepare for an `update` cycle
    def refresh
      @data = self.get.map do |station|
        station['stop_code'] = station['name'][/BUS\w*|TEMP\w*/].chomp
        mapped_info = ATTRIBUTE_MAP.each_with_object({}) do |(prop, name), h|
          h[prop] = station[name]
        end
        [station[@key], mapped_info]
      end.to_h
    end

    # Iterate through the local cache of data, activating and updating objects
    # on the given manager as they come up
    def update manager
      @data.each do |key, info|
        # If the station already exists in the manager, load it. Otherwise,
        # create a new one.
        station = manager.find_or_new(key)
        # Update the information on the Station object to match the current
        # data from the source
        station.assign(info)
        # Ensure that the station is active in the manager
        manager.activate(station)
      end
    end
  end
end
