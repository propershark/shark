# Route event handlers for Conductor
class Conductor
  # update -> [route] {**defaults}
  #   heartbeat
  # Provides `route` as a hash of new attributes for a Route object. The
  # attributes given in this hash will always be enough to create a new Route
  # from scratch.
  register_handler 'routes', :update do |channel, args, kwargs|
    # The first argument of this event is the hash of attributes for the route
    # this update affects.
    route = args.first

    # Associations on Stations are created/destroyed by activate/deactivate
    # events, but this information is not static: a route can potentially
    # change it's stop list while it is active.
    route_inst = @storage.find(channel)
    # To ensure all changes are propogated up and to avoid conflicts, clear all
    # existing associations first.
    route_inst.associated_objects[Shark::Station].each do |station_id|
      if station = @storage.find(station_id)
        station.dissociate(Shark::Route, channel)
      end
      route_inst.dissociate(Shark::Station, station_id)
    end
    # Then recreate the ones that still exist or have been added.
    route_inst.stations.each do |station_id|
      if station = @storage.find(station_id)
        station.associate(Shark::Route, channel)
      end
      # Create back-associations as well to allow the associations to be found
      # instantly rather than iteratively.
      route_inst.associate(Shark::Station, station_id)
    end if route_inst.stations
  end


  # activate -> [route] {**defaults}
  #   once
  # Sent when a Route becomes publicly visible. `route` will be an attributes
  # hash equivalent to that in the update event.
  register_handler 'routes', :activate do |channel, args, kwargs|
    # The first argument of this event is the hash of attributes for the route
    # this update affects.
    route = args.first

    # Find the Shark::Station instances for each station that this route
    # touches, and create an association to this route on those instances.
    route_inst = @storage.find(channel)
    route_inst.stations.each do |station_id|
      if station = @storage.find(station_id)
        station.associate(Shark::Route, channel)
      end
      # Create back-associations as well to allow the associations to be found
      # instantly rather than iteratively.
      route_inst.associate(Shark::Station, station_id)
    end if route_inst.stations
  end


  # deactivate -> [route] {**defaults}
  #   once
  # Sent when a Route stops being publicly visible. `route` will be an
  # attributes hash equivalent to that in the update event.
  register_handler 'routes', :deactivate do |channel, args, kwargs|
    # The first argument of this event is the hash of attributes for the route
    # this update affects.
    route = args.first

    # Find the Shark::Station instances for each station that this route
    # touches, and create an association to this route on those instances.
    route_inst = @storage.find(channel)
    route_inst.associated_object[Shark::Station].each do |station_id|
      if station = @storage.find(station_id)
        station.dissociate(Shark::Route, channel)
      end
    end
  end


  # vehicle_update -> [vehicle] {**defaults}
  #   heartbeat
  # Provides `vehicle` as a hash of attributes for a Vehicle object that is
  # currently traveling on this Route.
  register_handler 'routes', :vehicle_update do |channel, args, kwargs|
    # No conducting is needed
  end
end
