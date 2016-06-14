require 'wamp_client'
require 'rufus-scheduler'

require './vehicle.rb'

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

$scheduler.every '2s' do
  puts "Polling"

  @vehicles = {}
  (DoubleMap::Vehicles.next || []).each do |vehicle_info|
    (@vehicles[vehicle_info[:code]] ||= Shark::Vehicle.new).update vehicle_info
  end


  @vehicles.each do |code, vehicle|
    puts "pushing #{vehicle.channel_name}"
    @session.publish(vehicle.channel_name, [], vehicle.attrs) do |publish, error, details|
      puts publish
      puts error
      puts details
    end
  end
  sleep(2.5)
  puts "Done sleeping"
end

$transport.open
