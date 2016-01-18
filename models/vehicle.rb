class Vehicle < ActiveRecord::Base
  include AgeTracking
  include SourcedAttributes

  belongs_to :route
  belongs_to :trip
  belongs_to :next_stop, class_name: 'Stop'
  belongs_to :last_stop, class_name: 'Stop'

  # By default, only return vehicles that have been updated in the last 5 minutes
  scope :active, -> { where('last_update > ?', Time.now.seconds_since_midnight - 15*60) }

  # DoubleMap API
  sources_attributes_from :doublemap do
    configure   agency: :citybus, endpoint: :vehicles

    primary_key       :code

    attributes        :last_update
    aliased_attribute :doublemap_id, :id
    aliased_attribute :latitude, :lat
    aliased_attribute :longitude, :lon
    conditional_attribute :departed_at
    conditional_attribute :started_at

    association       :route,     primary_key: :doublemap_id
    # DoubleMap gives `last_stop`, while CityBus gives `next_stop`
    association       :last_stop, primary_key: :doublemap_id
  end

  # CityBus API
  sources_attributes_from :citybus do
    configure   endpoint: :vehicles

    primary_key       :code

    aliased_attribute :heading, :direction
    aliased_attribute :saturation, :capacity
    aliased_attribute :citybus_id, :id

    association       :next_stop, primary_key: :code
    attributes        :arriving_at
  end

  # Deduce the trip that this vehicle should be on from the route that it is on
  # and the time that it started its trip.
  def current_trip time=nil
    time ||= Time.now.midnight + started_at
    Trip.active(time).with_schedules \
      .where(route: route) \
      .having('? BETWEEN start_time AND end_time', started_at) \
      .order('start_time DESC').first
  end

  # The estimated duration from now until this vehicle arrives at other.
  def time_until_arrival_at other
    if next_stop_time = current_trip.stop_times.find_by(stop: other)
      next_stop_time.interpolated_arrival_time - Time.now.seconds_since_midnight
    else
      nil
    end
  end

  # The estimated duration from now until this vehicle departs from other.
  def time_until_departure_from other
    if next_stop_time = current_trip.stop_times.find_by(stop: other)
      next_stop_time.interpolated_arrival_time - Time.now.seconds_since_midnight
    else
      nil
    end
  end

  def stops_until other
  end
end
