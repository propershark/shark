module DoubleMapSource
  class StationSource < Source
    def refresh
      # For each station, create a hash of the values of each attribute and add
      # that hash to the data hash, indexed by the primary key specified in
      # the configuration of this Source.
      @data = api.stops.all.map do |stop|
        attrs = @station_attributes.map{ |prop, name| [prop, stop.send(name)] }.to_h
        # NOTE: This is a little awkward and brittle, but it ensures that
        # stop_code (which is often the primary_attribute of a Station) is set
        # for all objects.
        attrs[:stop_code] = @station_key.call(stop)
        [@station_key.call(stop), attrs]
      end.to_h
    end
  end

  register_source :doublemap, Shark::Station, StationSource
end
