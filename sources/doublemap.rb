require 'doublemap_api'
require_relative '../source.rb'

module DoubleMapSource
  extend Shark::Source

  class Source < Shark::Source::NormalSource
    include Shark::Configurable
    inherit_configuration_from DoubleMapSource

    def doublemap
      @doublemap ||= begin
        DoubleMap.configure do |config|
          config.base_uri     = "http://#{@agency}.doublemap.com/"
          config.adapter      = :httparty
          config.debug_output = false
        end
        DoubleMap.new
      end
    end
  end

  register_source :doublemap, Shark::Route, DoubleMapSource::Source
end

# require_relative 'doublemap/route'
# require_relative 'doublemap/station'
# require_relative 'doublemap/vehicle'
