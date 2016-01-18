# Returns a list of Stops within a certain distance of the
post '/stops/nearby' do
end

# Returns all of the information for a Stop, and the vehicles that will
# pass through the stop.
get '/stops/:id' do
  @stop = Stop.includes(:vehicles, :routes).find(params[:id])
  haml :stop
end

get '/routes/:id' do
  @route = Route.includes(:vehicles, :stops).find(params[:id])
  haml :route
end
