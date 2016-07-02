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
    # Only continue if this was a vehicle update
    return unless channel.start_with? @vehicle_namespace

    vehicle = args.first
    route_vehicle_update(vehicle, channel)
  end

  # Publish a vehicle_update to the Route that this vehicle belongs to.
  def route_vehicle_update vehicle, originator
    route_id = vehicle[:route]
    route = @storage.find(route_id)
    if route
      puts "#{vehicle[:name]} is traveling on #{route.short_name} - #{route.name}"
      @app.call(:vehicle_update, route_id, vehicle, { originator: originator })
    end
  end
end
