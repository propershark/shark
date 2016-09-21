require_relative '../middlewares/normalizer'

Normalizer.configure do |config|
  # Remove Station `stop_code`s from their names (they are extracted into
  # `Station#stop_code` at the Source level).
  config.on_shark_station = Proc.new do |station|
    station.name = station.name.sub(/\s*\W*\s*(BUS|TEMP)\d+\s*$/, '')
  end

  # Remove any miscellaneous information from Route names. In particular,
  # schedule information will be sourced from the Timetable server, so having
  # such information in the Route name will be misleading, if nothing else.
  config.on_shark_route = Proc.new do |route|
    route.name = route.name.sub(/\(Begins[^\)]+\)/, '')
  end
end
