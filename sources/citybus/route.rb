require 'set'

module CityBus
  class RouteSource < Source
    class << self
      # The list of Route-Direction pairs that can be used to retrieve vehicle
      # information. CityBus, interestingly, does not provide a way to retrieve
      # all vehicles without knowing all of the Routes and Directions to which
      # they belong.
      attr_accessor :route_direction_pairs
    end

    # A key-value map of attributes on the Route class to entries in the
    # source data
    ATTRIBUTE_MAP = {
      name: 'Name',
      short_name: 'ShortName',
      description: 'Description',
      color: 'Color',
      patterns: 'PatternList'
    }

    # Update the local cache of data to prepare for an `update` cycle
    def refresh
      rd_pairs = Set.new
      @data = self.post
      @data.each do |route|
        route['PatternList'].each do |pattern|
          rd_pairs << [route['Key'], pattern['Direction']['DirectionKey']]
        end
      end
      self.class.route_direction_pairs = rd_pairs
    end

    # Iterate through the local cache of data, activating and updating objects
    # on the given manager as they come up
    def update manager
      # TODO: determine importance of implementing update, since no attributes
      # are actively being used from this source.
    end
  end
end
