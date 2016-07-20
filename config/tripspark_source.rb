require_relative '../sources/tripspark'

# Configuration for all CityBus source objects
TripSparkSource.configure do |ts|
  ts.configure_api  = Proc.new do |config|
    config.base_uri     = 'http://bus.gocitybus.com/'
    config.adapter      = :httparty
    config.debug_output = false
  end


  ts.route_key      = :short_name
  ts.station_key    = :stop_code
  ts.vehicle_key    = :name

  ts.route_attributes = {
    name:         :name,
    short_name:   :short_name,
    description:  :description
  }

  # DoubleMap provides all of the information on Stations that CityBus needs.
  ts.station_attributes = { }

  ts.vehicle_attributes = {
    name:         :name,
    capacity:     :capacity,
    onboard:      :onboard,
    saturation:   :saturation,
    heading:      :heading,
    speed:        :speed
  }
end
