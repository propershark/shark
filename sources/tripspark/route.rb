module TripSparkSource
  class RouteSource < Source
    def refresh
      api.flush_cache
      # For each route, create a hash of the values of each attribute and add
      # that hash to the data hash, indexed by the primary key specified in
      # the configuration of this Source.
      @data = api.routes.all.map do |route|
        attrs = @route_attributes.map{ |prop, name| [prop, route.send(name)] }.to_h
        ["routes."+@route_key.call(route), attrs]
      end.to_h
    end
  end

  register_source :tripspark, Shark::Route, RouteSource
end
