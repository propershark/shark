require 'tripspark_api'
require_relative '../source.rb'

module TripSparkSource
  extend Shark::Source

  class Source < Shark::Source::NormalSource
    include Shark::Configurable
    inherit_configuration_from TripSparkSource

    def read_configuration
      @route_attributes   ||= configuration.route_attributes
      @station_attributes ||= configuration.station_attributes
      @vehicle_attributes ||= configuration.vehicle_attributes
      # These keys can either be symbols or procs/lambdas. To normalize their
      # usage here, they will always be converted to procs.
      @route_key          ||= configuration.route_key.to_proc
      @station_key        ||= configuration.station_key.to_proc
      @vehicle_key        ||= configuration.vehicle_key.to_proc
    end

    # All sources will (likely) use the same API configuration, so it can be
    # exposed here to simplify their implementations.
    def api
      @api ||= begin
        # This is configuring the gem, not this source
        TripSpark.configure(&configuration.configure_api)
        TripSpark.new
      end
    end
  end
end

require_relative 'tripspark/route'
require_relative 'tripspark/station'
require_relative 'tripspark/vehicle'
