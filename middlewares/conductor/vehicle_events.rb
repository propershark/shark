# Vehicle event handlers for Conductor
class Conductor
  # update -> [vehicle] {**defaults}
  #   heartbeat
  # Provides `vehicle` as a hash of new attributes for a Vehicle object. The
  # attributes given in this hash will always be enough to create a new Vehicle
  # from scratch.
  register_handler 'vehicles', :update do |event|
    # The first argument of this event is the vehicle object this update affects
    vehicle = event.args.first

    # If the last station still has an association to this vehicle, terminate
    # that relationship and send a `depart` event to the station.
    last_station_id = vehicle.last_station
    if (last_station = @storage.find(last_station_id)) && last_station.has_association_to(Shark::Vehicle, event.topic)
      last_station.dissociate(Shark::Vehicle, event.topic)
      fire(Shark::Event.new(
        topic: last_station_id,
        type: :depart,
        args: [vehicle],
        kwargs: {},
        originator: event.topic
      ))
    end

    # The opposite is necessary for the next station: if it does not yet have
    # an association to this vehicle, create one.
    next_station_id = vehicle.next_station
    if next_station = @storage.find(next_station_id)
      next_station.associate(Shark::Vehicle, event.topic)
    end

    # Find the Shark::Route instance of the route that this vehicle is
    # traveling on, and only continue if that route exists
    route_id = vehicle.route
    if route = @storage.find(route_id)
      # Ensure that the Route has an association to the vehicle. If the
      # association did not already exist, add it, and send a route update
      # to ensure all clients know the vehicles currently on the route.
      if !route.has_association_to(Shark::Vehicle, event.topic)
        route.associate(Shark::Vehicle, event.topic)
        fire(Shark::Event.new(
          topic: route_id,
          type: :update,
          args: [route],
          kwargs: {},
          originator: event.topic
        ))
      end
      # Publish a vehicle_update event to the route. Since the vehicle caused the
      # event to occur, it should be the originator.
      fire(Shark::Event.new(
        topic: route_id,
        type: :vehicle_update,
        args: [vehicle],
        kwargs: {},
        originator: event.topic
      ))
    end
  end


  # activate -> [vehicle] {**defaults}
  #   once
  # Sent when a Vehicle becomes publicly visible. `vehicle` will be an
  # attributes hash equivalent to that in the `update` event.
  register_handler 'vehicles', :activate do |event|
    # The first argument of this event is the vehicle object this update affects
    vehicle = event.args.first

    # Create an association on the next station this vehicle will arrive at.
    next_station_id = vehicle.next_station
    if next_station = @storage.find(next_station_id)
      next_station.associate(Shark::Vehicle, event.topic)
    end

    # Find the Shark::Route instance of the route that this vehicle is
    # traveling on, and only continue if that route exists
    route_id = vehicle.route
    if route = @storage.find(route_id)
      # Ensure that the Route has an association to the vehicle. If the
      # association did not already exist, add it, and send a route update
      # to ensure all clients know the vehicles currently on the route.
      if !route.has_association_to(Shark::Vehicle, event.topic)
        route.associate(Shark::Vehicle, event.topic)
        fire(Shark::Event.new(
          topic: route_id,
          type: :update,
          args: [route],
          kwargs: {},
          originator: event.topic
        ))
      end
      # Publish a vehicle_update event to the route. Since the vehicle caused the
      # event to occur, it should be the originator.
      fire(Shark::Event.new(
        topic: route_id,
        type: :vehicle_update,
        args: [route],
        kwargs: {},
        originator: event.topic
      ))
    end
  end


  # deactivate -> [vehicle] {**defaults}
  #   once
  # Sent when a Vehicle stops being publicly visible. `vehicle` will be an
  # attributes hash equivalent to that in the `update` event.
  register_handler 'vehicles', :deactivate do |event|
    # The first argument of this event is the vehicle object this update affects
    vehicle = event.args.first

    # Destroy all associations currently applying to this vehicle.
    last_station_id = vehicle.last_station
    if last_station = @storage.find(last_station_id)
      last_station.dissociate(Shark::Vehicle, event.topic)
    end
    next_station_id = vehicle.next_station
    if next_station = @storage.find(next_station_id)
      next_station.dissociate(Shark::Vehicle, event.topic)
    end
    route_id = vehicle.route
    if route = @storage.find(route_id)
      route.dissociate(Shark::Vehicle, event.topic)
    end
  end
end
