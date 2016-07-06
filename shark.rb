require_relative 'agency'
require_relative 'config/citybus'

# Initialize the CityBus agency from it's configuration file.
$citybus = Shark::Agency.new
# Start running the services the agency provides.
$citybus.run

# `Agency#run` is asynchronous (all services run in background threads), so
# this thread (as the master thread) needs to stay open while they run. Since
# there are no other tasks to perform, this thread can just sleep forever.
sleep
