require 'wamp_client'
require 'rufus-scheduler'

require './object_manager.rb'
require './objects/vehicle.rb'

require './sources/doublemap.rb'
require './sources/doublemap/vehicle.rb'

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


$vehicle_manager = Shark::ObjectManager.new 'id'
$vehicle_manager.add_source(DoubleMap::VehicleSource.new('citybus', 'buses', 'id'))


$scheduler.every '4s' do
  $vehicle_manager.update

  $vehicle_manager.each do |vehicle|
    channel_name = "com.propershark.vehicles.#{vehicle['id']}"
    puts "Publishing update to channel #{channel_name}"
    @session.publish("com.propershark.vehicles.all", [vehicle])
  end
end

$transport.open
