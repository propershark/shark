module DoubleMap
  class StationSource < Source
    # A key-value map of attributes on the Station class to entries in the
    # source data
    ATTRIBUTES = [
      'name',
      'description',
      'lat',
      'lon',
      'stop_code'
    ]

    # Update the local cache of data to prepare for an `update` cycle
    def refresh
      # For each station, create a hash of the values of each attribute and add
      # that hash to the data hash, indexed by the primary key specified in
      # the configuration of this Source.
      @data = doublemap.stops.all.map do |stop|
        [stop.send(@key), ATTRIBUTES.map{ |name| [name, stop.send(name)] }.to_h]
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
