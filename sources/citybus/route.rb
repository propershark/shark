require 'set'

module CityBus
  class RouteSource < Source
    ATTRIBUTES = [
      'name',
      'short_name',
      'description'
    ]

    # Update the local cache of data to prepare for an `update` cycle
    def refresh
      # For each route, create a hash of the values of each attribute and add
      # that hash to the data hash, indexed by the primary key specified in
      # the configuration of this Source.
      @data = tripspark.routes.all.map do |route|
        [route.send(@key), ATTRIBUTES.map{ |name| [name, route.send(name)] }.to_h]
      end.to_h
    end

    # Iterate through the local cache of data, activating and updating objects
    # on the given manager as they come up
    def update manager
      @data.each do |key, info|
        # If the route already exists in the manager, load it. Otherwise,
        # create a new one.
        route = manager.get(key) || ::Shark::Route.new
        # Update the information on the Route object to match the current
        # data from the source
        route.assign(info)
        # Ensure that the route is active in the manager
        manager.activate(route)
      end
    end
  end
end
