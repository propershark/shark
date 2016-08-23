require 'pstore'

require_relative '../agency'
require_relative '../config/citybus'

Shark::Object.configure{}

STORAGE = PStore.new('data/events.log')
# Running this task will recreate the event log from scratch
STORAGE.transaction{ STORAGE.delete :eventlog }


# Create an agency instance and overwrite `call` to intercept all events that
# it receives (from ObjectManagers) and record them appropriately.
mock_agency = Shark::Agency.new
def mock_agency.call event
  # Record the given event into persistant storage, along with a timestamp for
  # remember it's position in an order of events.
  time = Time.now
  (STORAGE[:eventlog] ||= {})[time] = event.to_h
  puts "Recorded #{event.topic}##{event.type} at #{time}"
end

STORAGE.transaction do
  mock_agency.run
  sleep(4)
end
