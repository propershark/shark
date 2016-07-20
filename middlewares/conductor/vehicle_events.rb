# Vehicle event handlers for Conductor
class Conductor
  # update -> [vehicle] {**defaults}
  #   heartbeat
  # Provides `vehicle` as a hash of new attributes for a Vehicle object. The
  # attributes given in this hash will always be enough to create a new Vehicle
  # from scratch.
  register_handler 'vehicles', :update do |channel, args, kwargs|
    # The first argument of this event is the hash of attributes for the vehicle
    # this update affects.
    vehicle = args.first

    # If the last station still has an association to this vehicle, terminate
    # that relationship and send a `depart` event to the station.
    last_station_id = vehicle[:last_station]
    if (last_station = @storage.find(last_station_id)) && last_station.has_association_to(Shark::Vehicle, channel)
      last_station.dissociate(Shark::Vehicle, channel)
      @app.call(:depart, last_station_id, vehicle, { originator: channel })
    end

    # The opposite is necessary for the next station: if it does not yet have
    # an association to this vehicle, create one.
    next_station_id = vehicle[:next_station]
    if next_station = @storage.find(next_station_id)
      next_station.associate(Shark::Vehicle, channel)
    end

    # Find the Shark::Route instance of the route that this vehicle is
    # traveling on, and only continue if that route exists
    route_id = vehicle[:route]
    if route = @storage.find(route_id)
      # Ensure that the Route has an association to the vehicle. If the
      # association did not already exist, add it, and send a route update
      # to ensure all clients know the vehicles currently on the route.
      if !route.has_association_to(Shark::Vehicle, channel)
        route.associate(Shark::Vehicle, channel)
        @app.call(:update, route_id, route, { originator: channel })
      end
      # Publish a vehicle_update event to the route. Since the vehicle caused the
      # event to occur, it should be the originator.
      @app.call(:vehicle_update, route_id, vehicle, { originator: channel })
    end
  end


  # activate -> [vehicle] {**defaults}
  #   once
  # Sent when a Vehicle becomes publicly visible. `vehicle` will be an
  # attributes hash equivalent to that in the `update` event.
  register_handler 'vehicles', :activate do |channel, args, kwargs|
    # The first argument of this event is the hash of attributes for the vehicle
    # this update affects.
    vehicle = args.first

    # Create an association on the next station this vehicle will arrive at.
    next_station_id = vehicle[:next_station]
    if next_station = @storage.find(next_station_id)
      next_station.associate(Shark::Vehicle, channel)
    end

    # Find the Shark::Route instance of the route that this vehicle is
    # traveling on, and only continue if that route exists
    route_id = vehicle[:route]
    if route = @storage.find(route_id)
      # Ensure that the Route has an association to the vehicle. If the
      # association did not already exist, add it, and send a route update
      # to ensure all clients know the vehicles currently on the route.
      if !route.has_association_to(Shark::Vehicle, channel)
        route.associate(Shark::Vehicle, channel)
        @app.call(:update, route_id, route.to_h, { originator: channel })
      end
      # Publish a vehicle_update event to the route. Since the vehicle caused the
      # event to occur, it should be the originator.
      @app.call(:vehicle_update, route_id, vehicle, { originator: channel })
    end
  end


  # deactivate -> [vehicle] {**defaults}
  #   once
  # Sent when a Vehicle stops being publicly visible. `vehicle` will be an
  # attributes hash equivalent to that in the `update` event.
  register_handler 'vehicles', :deactivate do |channel, args, kwargs|
    # The first argument of this event is the hash of attributes for the vehicle
    # this update affects.
    vehicle = args.first

    # Destroy all associations currently applying to this vehicle.
    last_station_id = vehicle[:last_station]
    if last_station = @storage.find(last_station_id)
      last_station.dissociate(Shark::Vehicle, channel)
    end
    next_station_id = vehicle[:next_station]
    if next_station = @storage.find(next_station_id)
      next_station.dissociate(Shark::Vehicle, channel)
    end
    route_id = vehicle[:route]
    if route = @storage.find(route_id)
      route.dissociate(Shark::Vehicle, channel)
    end
  end
end
