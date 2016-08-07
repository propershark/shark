# Route event handlers for Conductor
class Conductor
  # Create an association on the station identified by `station_id` to the
  # given route. Additionally, create a back-association on `route`.
  def re_associate_to_station route, station_id
    route_id = Shark::Route.identifier_for(route.identifier)
    if station = @storage.find(station_id)
      station.associate(Shark::Route, route_id)
    end
    route.associate(Shark::Station, station_id)
  end

  # Remove an association on `route` to the given station
  def re_dissociate_from_station route, station_id
    route_id = Shark::Route.identifier_for(route.identifier)
    if station = @storage.find(station_id)
      station.dissociate(Shark::Route, route_id)
    end
    route.dissociate(Shark::Station, station_id)
  end

  # Embed useful information about stations into a Route object. `route` should
  # be the Hash representation of the Route object, and it will be modified in-
  # place.
  #
  # See https://github.com/propershark/shark/issues/5 for discussion.
  def re_embed_objects! route
    # Each station in the `station` attribute gets embedded as a hash of the
    # `identifier` and `name` attributes of that station.
    route.stations&.map! do |station_id|
      station = @storage.find(station_id)
      { identifier: station_id, name: station&.name }
    end
  end


  # update -> [route] {**defaults}
  #   heartbeat
  # Provides `route` as a hash of new attributes for a Route object. The
  # attributes given in this hash will always be enough to create a new Route
  # from scratch.
  register_handler 'routes', :update do |channel, args, kwargs|
    # The first argument of this event is the route object this update affects
    route = args.first

    # Associations on Stations are created/destroyed by activate/deactivate
    # events, but this information is not static: a route can potentially
    # change it's stop list while it is active.
    # To ensure all changes are propogated up and to avoid conflicts, clear all
    # existing associations first.
    route.associated_objects[Shark::Station].each do |station_id|
      re_dissociate_from_station(route, station_id)
    end
    # Then recreate the ones that still exist or have been added.
    route.stations&.each do |station_id|
      re_associate_to_station(route, station_id)
    end

    # Embed station information into the route
    re_embed_objects! route
  end


  # activate -> [route] {**defaults}
  #   once
  # Sent when a Route becomes publicly visible. `route` will be an attributes
  # hash equivalent to that in the update event.
  register_handler 'routes', :activate do |channel, args, kwargs|
    # The first argument of this event is the route object this update affects
    route = args.first

    # Find the Shark::Station instances for each station that this route
    # touches, and create an association to this route on those instances.
    route.stations&.each do |station_id|
      re_associate_to_station(route, station_id)
    end

    # Embed station information into the route
    re_embed_objects! route
  end


  # deactivate -> [route] {**defaults}
  #   once
  # Sent when a Route stops being publicly visible. `route` will be an
  # attributes hash equivalent to that in the update event.
  register_handler 'routes', :deactivate do |channel, args, kwargs|
    # The first argument of this event is the route object this update affects
    route = args.first

    # Find the Shark::Station instances for each station that this route
    # touches, and create an association to this route on those instances.
    route.associated_object[Shark::Station].each do |station_id|
      re_dissociate_from_station(route, station_id)
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
