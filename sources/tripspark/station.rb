# DoubleMap provides all of the information on Stations that we need, in a much
# simpler format, so this source is rather unnecessary. Because of that, and
# the awkwardly-formatted API for retrieving stations from CityBus, this source
# will go unimplemented until the system is generalized for other agencies.
module TripSparkSource
  class StationSource < Source
    def refresh
      # TODO: determine importance of implementation
    end
  end

  register_source :tripspark, Shark::Station, StationSource
end
