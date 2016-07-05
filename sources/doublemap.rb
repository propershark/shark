require 'doublemap_api'
require_relative '../source.rb'

module DoubleMapSource
  extend Shark::Source

  class Source < Shark::Source::NormalSource
    include Shark::Configurable
    inherit_configuration_from DoubleMapSource

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
        DoubleMap.configure do |config|
          config.base_uri     = "http://#{configuration.agency}.doublemap.com/"
          config.adapter      = :httparty
          config.debug_output = false
        end
        DoubleMap.new
      end
    end
  end
end

require_relative 'doublemap/route'
require_relative 'doublemap/station'
require_relative 'doublemap/vehicle'
