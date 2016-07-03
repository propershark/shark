require './core_ext/hash.rb'
require './hacks/doublemap_api/models/stop.rb'
require './agency.rb'

require_relative 'middlewares/conductor'
require_relative 'middlewares/transport'

# Set up the Middleware stack for all agencies
Shark::Agency.use_middleware Transport, config_file: 'config/transport.yml'
Shark::Agency.use_middleware Conductor, vehicle_namespace: 'vehicles.'

# Initialize the CityBus agency from it's configuration file.
$citybus = Shark::Agency.new(config_file: 'config/citybus.yml')
# Start running the services the agency provides.
$citybus.run

# `Agency#run` is asynchronous (all services run in background threads), so
# this thread (as the master thread) needs to stay open while they run. Since
# there are no other tasks to perform, this thread can just sleep forever.
sleep
