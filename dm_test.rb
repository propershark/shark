require 'rufus-scheduler'

require './object.rb'
require './objects/vehicle.rb'
require './objects/route.rb'
require './objects/station.rb'
require './object_manager.rb'
require './event_handler.rb'

require './sources/doublemap.rb'
require './sources/doublemap/vehicle.rb'
require './sources/doublemap/route.rb'
require './sources/doublemap/station.rb'

require './transport.rb'

# Initialize the Transport layer and start the connection in a separate thread.
$transport = Shark::Transport.new
transport_thread = Thread.new{ $transport.open }
# Wait for the connection to be established.
sleep(0.1) until $transport.is_open?


# Initialize the scheduler for all timed updates
$scheduler = Rufus::Scheduler.new


# Initialize the object managers
$vehicle_manager = Shark::ObjectManager.new(
  event_handler: Shark::WebSocketEventHandler.new(
    namespace: 'com.propershark.vehicles',
    transport: $transport.session
  ),
  sources: [
    DoubleMap::VehicleSource.new('citybus', 'buses', 'id')
  ]
)

$route_manager = Shark::ObjectManager.new(
  event_handler: Shark::WebSocketEventHandler.new(
    namespace: 'com.propershark.routes',
    transport: $transport.session
  ),
  sources: [
    DoubleMap::RouteSource.new('citybus', 'routes', 'id')
  ]
)

$station_manager = Shark::ObjectManager.new(
  event_handler: Shark::WebSocketEventHandler.new(
    namespace: 'com.propershark.stations',
    transport: $transport.session
  ),
  sources: [
    DoubleMap::StationSource.new('citybus', 'stops', 'id')
  ]
)


# Add update schedules
$scheduler.every(' 2s'){ $vehicle_manager.update }
$scheduler.every(' 4s'){ $route_manager.update }
$scheduler.every('10s'){ $station_manager.update }


transport_thread.join
