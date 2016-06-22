# DoubleMap provides all of the information on Stations that we need, in a much
# simpler format, so this source is rather unnecessary. Because of that, and
# the awkwardly-formatted API for retrieving stations from CityBus, this source
# will go unimplemented until the system is generalized for other agencies.
module CityBus
  class StationSource < Source
    # A key-value map of attributes on the Station class to entries in the
    # source data
    ATTRIBUTE_MAP = {
      # TODO: Implementation.
    }

    # Update the local cache of data to prepare for an `update` cycle
    def refresh
      # TODO: Implementation.
    end

    # Iterate through the local cache of data, activating and updating objects
    # on the given manager as they come up
    def update manager
      # TODO: Implementation.
    end
  end
end
