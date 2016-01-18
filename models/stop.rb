class Stop < ActiveRecord::Base
  include AgeTracking
  include SourcedAttributes

  has_many :route_stops, autosave: true
  has_many :routes, through: :route_stops, autosave: true

  # CityBus GTFS Dump
  sources_attributes_from :gtfs do
    configure   source_file:  'data/citybus_gtfs_2015-10-31.zip', table: :stops

    primary_key       :code

    attributes        :name
    aliased_attribute :latitude, :lat
    aliased_attribute :longitude, :lon
    aliased_attribute :description, :desc
    aliased_attribute :citybus_id, :id
  end

  # DoubleMap API
  sources_attributes_from :doublemap, create_new: false do
    configure   agency: :citybus, endpoint: :stops

    primary_key       :code

    aliased_attribute :doublemap_id, :id
  end

  def next_vehicles limit=10
    # Get all vehicles that are currently running and will come through this stop
    vehicles = Vehicle.active \
      .joins(route: [trips: [:stop_times]]) \
      .where(stop_times: { stop_id: id }, trips: { service_id: Service.active.pluck(:id) }) \
      .uniq.all

    vehicles.sort_by{ |v| v.time_until_arrival_at self }
  end
end
