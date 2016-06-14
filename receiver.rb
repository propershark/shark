require 'wamp_client'

options = {
    uri: 'ws://io:8080/ws',
    realm: 'realm1',
    authid: 'testing',
    authmethods: ['anonymous']
}
connection = WampClient::Connection.new(options)

connection.on_join do |session, details|
  puts 'Session (re-)connected'

  session.subscribe('com.propershark.vehicles.all', lambda do |args, kwargs, details|
    puts 'position ' + args.first.to_s
    puts kwargs
  end)
end

connection.open
