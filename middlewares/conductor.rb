# A Middleware class for sending events about vehicles to stations in advance
# of their arrival and after their departure
class Conductor < Shark::Middleware
  def initialize app, vehicle_namespace:
    super(app)
    @vehicle_namespace = vehicle_namespace
  end

  def call event, channel, *args, **kwargs
    # Immediately pass the original event through to the next Middleware
    @app.call(event, channel, *args, kwargs)
    case channel
    when /#{Regexp.quote(@vehicle_namespace)}\..*/
      vehicle = args.first
      route_vehicle_update(vehicle, channel)
    end
  end

  # Publish a vehicle_update to the Route that this vehicle belongs to.
  def route_vehicle_update vehicle, originator
    route_id = vehicle[:route]
    route = @storage.find(route_id)
    # Only continue if the route exists as a full object
    return unless route
    # Ensure that the Route has an association to the vehicle
    route.associate(Shark::Vehicle, originator)
    # Publish a vehicle_update event to the route.
    puts "#{vehicle[:name]} is traveling on #{route.short_name} - #{route.name}"
    @app.call(:vehicle_update, route_id, vehicle, { originator: originator })
  end
end
