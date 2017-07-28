require 'bart_api'
require_relative '../source.rb'

module BartSource
  extend Shark::Source

  class Source < Shark::Source::NormalSource
    include Shark::Configurable
    inherit_configuration_from BartSource

    def read_configuration
      @route_attributes   ||= configuration.route_attributes
      @station_attributes ||= configuration.station_attributes
      @route_key          ||= configuration.route_key.to_proc
    end

    def api
      @api ||= begin
                 Bart.configure do |config|
                   config.api_key      = configuration.api_key
                   config.debug_output = configuration.debug_output
                 end
                 Bart.new
               end
    end
  end
end

require_relative 'bart/route'
require_relative 'bart/station'
