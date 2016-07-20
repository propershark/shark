# Station event handlers for Conductor
class Conductor
  # update -> [station] {**defaults}
  #   heartbeat
  # Provides `station` as a hash of new attributes for a Station object. The
  # attributes given in this hash will always be enough to create a new Station
  # from scratch.
  register_handler 'stations', :update do |channel, args, kwargs|
    # No conducting is necessary
  end

  # activate -> [station] {**defaults}
  #   once
  # Sent when a Station becomes publicly visible. `station` will be an
  # attributes hash equivalent to that in the update event.
  register_handler 'stations', :activate do |channel, args, kwargs|
    # No conducting is necessary
  end

  # deactivate -> [station] {**defaults}
  #   once
  # Sent when a Station stops being publicly visible. `station` will be an
  # attributes hash equivalent to that in the update event.
  register_handler 'stations', :deactivate do |channel, args, kwargs|
    # No conducting is necessary
  end

  # depart -> [vehicle] {**defaults}
  #   once
  # Sent when a vehicle departs from this Station. `vehicle` will be the
  # attributes of the vehicle that departed.
  register_handler 'stations', :depart do |channel, args, kwargs|
    # No conducting is necessary
  end
end
