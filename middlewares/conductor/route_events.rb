# Route event handlers for Conductor
class Conductor
  # update -> [route] {**defaults}
  #   heartbeat
  # Provides `route` as a hash of new attributes for a Route object. The
  # attributes given in this hash will always be enough to create a new Route
  # from scratch.
  register_handler 'routes', :update do |event|
    # The first argument of this event is the route object this update affects
    route = event.args.first

    # Associations on Stations are created/destroyed by activate/deactivate
    # events, but this information is not static: a route can potentially
    # change it's stop list while it is active.
    # To ensure all changes are propogated up and to avoid conflicts, clear all
    # existing associations first.
    route.associated_objects[Shark::Station].each do |station|
      dissociate_mutual(route, station)
    end
    # Then recreate the ones that still exist or have been added.
    route.stations&.each{ |station| associate_mutual(route, station) }
  end


  # activate -> [route] {**defaults}
  #   once
  # Sent when a Route becomes publicly visible. `route` will be an attributes
  # hash equivalent to that in the update event.
  register_handler 'routes', :activate do |event|
    # The first argument of this event is the route object this update affects
    route = event.args.first

    # Find the Shark::Station instances for each station that this route
    # touches, and create an association to this route on those instances.
    route.stations&.each{ |station| associate_mutual(route, station) }
  end


  # deactivate -> [route] {**defaults}
  #   once
  # Sent when a Route stops being publicly visible. `route` will be an
  # attributes hash equivalent to that in the update event.
  register_handler 'routes', :deactivate do |event|
    # The first argument of this event is the route object this update affects
    route = event.args.first

    # Find the Shark::Station instances for each station that this route
    # touches, and create an association to this route on those instances.
    route.associated_objects[Shark::Station].each do |station|
      dissociate_mutual(route, station)
    end
  end


  # vehicle_update -> [vehicle] {**defaults}
  #   heartbeat
  # Provides `vehicle` as a hash of attributes for a Vehicle object that is
  # currently traveling on this Route.
  register_handler 'routes', :vehicle_update do |event|
    # No conducting is needed
  end
end
