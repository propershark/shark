require_relative '../sources/doublemap'

# Configuration for all DoubleMap source objects
DoubleMapSource.configure do |doublemap|
  doublemap.agency      = :citybus
  doublemap.route_key   = :short_name
  # DoubleMap does not have :stop_code as part of it's schema, but it is useful
  # for creating shorter channel names. This lambda essentially patches
  # stop_code onto DoubleMap::Station objects.
  doublemap.station_key = ->(station){ station.name[/BUS\w*|TEMP\w*/].chomp }
  doublemap.vehicle_key = :name


  doublemap.route_attributes = {
    code:         :id,
    name:         :name,
    short_name:   :short_name,
    description:  :description,
    color:        :color,
    path:         :path,
    itinerary:    :stops
  }

  doublemap.station_attributes = {
    name:         :name,
    description:  :description,
    latitude:     :lat,
    longitude:    :lon
  }

  doublemap.vehicle_attributes = {
    name:         :name,
    latitude:     :lat,
    longitude:    :lon
  }
end
