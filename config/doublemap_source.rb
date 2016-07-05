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
    color:        :color
  }

  doublemap.station_attributes = {
    name:         :name,
    description:  :description,
    lat:          :lat,
    lon:          :lon
  }

  doublemap.vehicle_attributes = {
    name:   :name,
    lat:    :lat,
    lon:    :lon
  }
end
