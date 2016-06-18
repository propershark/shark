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
require './agency.rb'

# Initialize the Transport layer and start the connection in a separate thread.
$transport = Shark::Transport.new
transport_thread = Thread.new{ $transport.open }
# Wait for the connection to be established.
sleep(0.1) until $transport.is_open?

# Initialize the scheduler for all timed updates
$scheduler = Rufus::Scheduler.new

# Initializd the CityBus agency and it's associated sources
$citybus = Shark::Agency.new(transport: $transport)
$citybus.vehicle_manager.add_source(DoubleMap::VehicleSource.new('citybus', 'buses', 'id'))
$citybus.route_manager.add_source(DoubleMap::RouteSource.new('citybus', 'routes', 'id'))
$citybus.station_manager.add_source(DoubleMap::StationSource.new('citybus', 'stops', 'id'))

# Add update schedules
$scheduler.every(' 2s'){ $citybus.vehicle_manager.update }
$scheduler.every(' 4s'){ $citybus.route_manager.update }
$scheduler.every('10s'){ $citybus.station_manager.update }

transport_thread.join
