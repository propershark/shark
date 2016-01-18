set :output, "/log/whenever.log"

# Update doublemap vehicle data every 5 seconds
every 5.seconds do
  runner "Vehicle.update_sourced_attributes(:doublemap)"
end
