class Route < ActiveRecord::Base
  include AgeTracking
  include SourcedAttributes

  has_many :route_stops, autosave: true
  has_many :stops, through: :route_stops, autosave: true
  has_many :vehicles, autosave: true
  has_many :trips

  # CityBus GTFS Dump
  sources_attributes_from :gtfs do
    # Live version available at http://myride.gocitybus.com/public/laf/GTFS/google_transit.zip
    configure   source_file:  'data/citybus_gtfs_2015-10-31.zip', table: :routes

    primary_key       :short_name

    attributes        :long_name, :color
    aliased_attribute :description, :desc
    aliased_attribute :citybus_id, :id
  end

  # DoubleMap API
  sources_attributes_from :doublemap do
    configure   agency: :citybus, endpoint: :routes

    primary_key       :short_name

    attributes        :active, :start_time, :end_time, :path
    aliased_attribute :url, :schedule_url
    aliased_attribute :doublemap_id, :id
  end
end
