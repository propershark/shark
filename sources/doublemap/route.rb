module DoubleMapSource
  class RouteSource < Source
    def refresh
      api.flush_cache
      @data = api.routes.all.select{ |r| check_valid r }.map do |route|
        attrs = @route_attributes.each_with_object({}) do |(prop, name), h|
          h[prop] = route.send(name)
        end
        # Convert the route's path from a flat list into pairs.
        attrs[:path]        = route.path.each_slice(2).to_a
        # Ensure that the short name of the route (commonly it's identifier) is set.
        attrs[:short_name]  = route.name.split.first if route.short_name.empty?
        attrs[:itinerary]    = route.stops.map do |stop_id|
          station_id = @station_key.call(api.stops.get(stop_id))
          Shark::Station.identifier_for(station_id) if station_id
        end.compact
        ["routes."+@route_key.call(route), attrs]
      end.to_h
    end

    def valid?(route)
      @route_key.call(route) &&
        @route_attributes.values.all? { |v| route.respond_to? v }
    end
  end

  register_source :doublemap, Shark::Route, RouteSource
end
