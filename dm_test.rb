require 'wamp_client'
require 'rufus-scheduler'

require './object.rb'
require './objects/vehicle.rb'
require './objects/route.rb'
require './objects/station.rb'
require './object_manager.rb'

require './sources/doublemap.rb'
require './sources/doublemap/vehicle.rb'
require './sources/doublemap/route.rb'
require './sources/doublemap/station.rb'

$scheduler = Rufus::Scheduler.new

$transport = WampClient::Connection.new({
  uri: 'ws://io:8080/ws',
  realm: 'realm1',
  authid: 'tester2',
  authmethods: ['anonymous']
})

$transport.on_join do |session, details|
  @session = session
end


$vehicle_manager = Shark::ObjectManager.new :code
$vehicle_manager.add_source(DoubleMap::VehicleSource.new('citybus', 'buses', 'id'))

$route_manager = Shark::ObjectManager.new :code
$route_manager.add_source(DoubleMap::RouteSource.new('citybus', 'routes', 'id'))

$station_manager = Shark::ObjectManager.new :code
$station_manager.add_source(DoubleMap::StationSource.new('citybus', 'stops', 'id'))

$scheduler.every '2s' do
  $vehicle_manager.update

  $vehicle_manager.each do |vehicle|
    channel_name = "com.propershark.vehicles.#{vehicle.code}"
    puts "Publishing update to channel #{channel_name}"
    puts vehicle.to_h
    @session.publish("com.propershark.vehicles.all", [vehicle.to_h])
  end
end

$scheduler.every '4s' do
  $route_manager.update

  $route_manager.each do |route|
    channel_name = "com.propershark.routes.#{route.short_name}"
    puts "Publishing update to channel #{channel_name}"
    @session.publish("com.propershark.routes.all", [route.to_h])
  end
end

$scheduler.every '10s' do
  $station_manager.update

  $station_manager.each do |station|
    channel_name = "com.propershark.stations.#{station.short_name}"
    puts "Publishing update to channel #{channel_name}"
    @session.publish("com.propershark.stations.all", [station.to_h])
  end
end

$transport.open
