class StopTime < ActiveRecord::Base
  include SourcedAttributes

  belongs_to :trip
  belongs_to :stop

  scope :timepoints, -> { where(is_timepoint: true) }

  sources_attributes_from :gtfs, batch_size: 2000 do
    configure   source_file:  'data/citybus_gtfs_2015-10-31.zip', table: :stop_times

    primary_key       :citybus_id, source: :_row_num

    attributes        :headsign, :pickup_type, :drop_off_type
    aliased_attribute :index, :stop_sequence
    aliased_attribute :distance_traveled, :shape_dist_traveled

    complex_attribute :arrival_time do |record|
      next nil unless record[:arrival_time]
      hours, mins, secs = record[:arrival_time].split(':').map(&:to_i)
      (hours.hours + mins.minutes + secs).to_i
    end

    complex_attribute :departure_time do |record|
      next nil unless record[:departure_time]
      hours, mins, secs = record[:departure_time].split(':').map(&:to_i)
      (hours.hours + mins.minutes + secs).to_i
    end

    complex_attribute :is_timepoint do |record|
      (record[:departure_time] && record[:arrival_time]) != nil
    end

    association :stop, primary_key: :citybus_id, source_key: :stop_id
    association :trip, primary_key: :citybus_id, source_key: :trip_id
  end

  def self.apply_interpolated_times
    transaction do
      updated_stops = StopTime.where('id > 123000').each do |st|
        st.update(
          departure_time: st.interpolated_departure_time,
          arrival_time: st.interpolated_arrival_time
        )
      end
    end
  end

  def self.clear_interpolated_times
    StopTime.where(is_timepoint: false).update_all(departure_time: nil, arrival_time: nil)
  end


  # The previous stop_time that was a timepoint on this trip.
  def prev_timepoint
    self.class.timepoints \
      .where(trip_id: trip_id) \
      .where('`stop_times`.`index` < ?', index) \
      .order(index: :desc) \
      .first
  end

  # The next stop_time that is a timepoint on this trip.
  def next_timepoint
    self.class.timepoints \
      .where(trip_id: trip_id) \
      .where('`stop_times`.`index` > ?', index) \
      .order(index: :asc) \
      .first
  end

  # The estimated departure time from this stop_time based on surrounding
  # timepoint and distance information.
  def interpolated_departure_time
    # If the stop is a timepoint, return the exact time
    return departure_time if departure_time
    # Otherwise, find the surrounding timepoints and interpolate between them
    all_stop_times = trip.stop_times.all
    stop_index = all_stop_times.find_index(self)
    # Get the surrounding timepoints
    prev_tp = prev_timepoint
    next_tp = next_timepoint
    # Find their indexes in the stop list
    prev_tp_index = all_stop_times.find_index(prev_tp)
    next_tp_index = all_stop_times.find_index(next_tp)
    # Find the total time between timepoints
    total_time_diff = next_tp.arrival_time - prev_tp.departure_time
    total_distance  = next_tp.distance_traveled - prev_tp.distance_traveled
    distance_from_tp = distance_traveled - prev_tp.distance_traveled
    # Determine how much of the time should have passed based on distance.
    fraction_traveled = distance_from_tp / total_distance
    # Return the previous departure time plus the appropriate fraction of
    # total time that should have passed.
    return prev_tp.departure_time + (total_time_diff * fraction_traveled)
  end

  # The estimated arrival time at this stop_time based on surrounding
  # timepoint and distance information.
  def interpolated_arrival_time
    # If the stop is a timepoint, return the exact time
    return arrival_time if arrival_time
    # Otherwise, find the surrounding timepoints and interpolate between them
    all_stop_times = trip.stop_times.all
    stop_index = all_stop_times.find_index(self)
    # Get the surrounding timepoints
    prev_tp = prev_timepoint
    next_tp = next_timepoint
    # Find their indexes in the stop list
    prev_tp_index = all_stop_times.find_index(prev_tp)
    next_tp_index = all_stop_times.find_index(next_tp)
    # Find the total time between timepoints
    total_time_diff = next_tp.arrival_time - prev_tp.departure_time
    total_distance  = next_tp.distance_traveled - prev_tp.distance_traveled
    distance_from_tp = distance_traveled - prev_tp.distance_traveled
    # Determine how much of the time should have passed based on distance.
    fraction_traveled = distance_from_tp / total_distance
    # Return the previous departure time plus the appropriate fraction of
    # total time that should have passed.
    return prev_tp.departure + (total_time_diff * fraction_traveled)
  end

  # The duration of time between departure from the given stop_time and this
  # one.
  def time_til_departure_from other
    other.interpolated_departure_time - interpolated_departure_time
  end

  # The duration of time between arrival at the given stop_time and this one.
  def time_til_arrival_at other
    other.interpolated_arrival_time - interpolated_arrival_time
  end

  # The number of stops (exclusive) between this given stop_time and this one
  def stops_until other
    all_stop_times = trip.stop_times.all
    all_stop_times.find_index(other) - all_stop_times.find_index(self)
  end
end
