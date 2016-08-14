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
    if dissociate(vehicle.last_station, from: vehicle)
      fire(Shark::Event.new(
        topic: vehicle.last_station,
        type: :depart,
        args: [vehicle],
        kwargs: {},
        originator: event.topic
      ))
    end

    # Create an association on the next station this vehicle will arrive at.
    associate(vehicle.next_station, to: vehicle)

    # Ensure that the Route has an association to the vehicle.
    associate(vehicle.route, to: vehicle)
    # Publish a `vehicle_update` event to the route. Since the vehicle caused
    # the event to occur, it should be the originator.
    fire(Shark::Event.new(
      topic: vehicle.route,
      type: :vehicle_update,
      args: [vehicle],
      kwargs: {},
      originator: event.topic
    ))
  end


  # activate -> [vehicle] {**defaults}
  #   once
  # Sent when a Vehicle becomes publicly visible. `vehicle` will be an
  # attributes hash equivalent to that in the `update` event.
  register_handler 'vehicles', :activate do |event|
    # The first argument of this event is the vehicle object this update affects
    vehicle = event.args.first

    # Create an association on the next station this vehicle will arrive at.
    associate(vehicle.next_station, to: vehicle)

    # Ensure that the Route has an association to the vehicle.
    associate(vehicle.route, to: event.topic, type: Shark::Vehicle)
    # Publish a `vehicle_update` event to the route. Since the vehicle caused
    # the event to occur, it should be the originator.
    fire(Shark::Event.new(
      topic: vehicle.route,
      type: :vehicle_update,
      args: [vehicle],
      kwargs: {},
      originator: event.topic
    ))
  end


  # deactivate -> [vehicle] {**defaults}
  #   once
  # Sent when a Vehicle stops being publicly visible. `vehicle` will be an
  # attributes hash equivalent to that in the `update` event.
  register_handler 'vehicles', :deactivate do |event|
    # The first argument of this event is the vehicle object this update affects
    vehicle = event.args.first

    # Destroy all associations currently applying to this vehicle.
    dissociate(vehicle.last_station,  from: vehicle)
    dissociate(vehicle.next_station,  from: vehicle)
    dissociate(vehicle.route,         from: vehicle)
    vehicle.dissociate_all
  end
end
