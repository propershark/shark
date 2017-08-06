require_relative '../sources/bart'

BartSource.configure do |bart|
  bart.api_key = 'MW9S-E7SL-26DU-VV8V'

  # BART keys its routes in GTFS with a 2-digit padded string, so we must
  # reflect that padding here.
  bart.route_key = ->(route){ "%02d" % route.id }

  bart.route_attributes = {
    code: :id,
    name: :name,
    color: :color
  }

  bart.station_attributes = {
    code: :abbr,
    name: :name,
    stop_code: :abbr,
    latitude: :latitude,
    longitude: :longitude
  }
end

