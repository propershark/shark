require 'tripspark_api'

# TODO:
# Technically, this could be generalized to "module TripSpark", as they service
# many different agencies across the country with the same software setup.
#
# Consider generalizing to work with different agencies.
module CityBus
  class Source
    def initialize key:
      @key = key
      @data = {}
    end

    def tripspark
      @tripspark ||= begin
        TripSpark.configure do |config|
          config.base_uri     = 'http://bus.gocitybus.com/'
          config.adapter      = :httparty
          config.debug_output = false
        end
        TripSpark.new
      end
    end
  end
end

require_relative 'citybus/route'
require_relative 'citybus/station'
require_relative 'citybus/vehicle'
