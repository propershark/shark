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
    next_station = @storage.find(vehicle[:next_station])
    if next_station
      puts "#{vehicle[:name]} will be arriving at \"#{next_station.name}\" next."
      @app.call(:vehicle_arrival, vehicle[:next_station], vehicle, { originator: channel })
    end
  end
end
