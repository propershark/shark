module DoubleMapSource
  class RouteSource < Source
    def refresh
      @data = api.routes.all.map do |route|
        attrs = @route_attributes.each_with_object({}) do |(prop, name), h|
          h[prop] = route.send(name)
        end
        # Convert the route's path from a flat list into pairs.
        attrs[:path]        = route.path.each_slice(2).to_a
        # Ensure that the short name of the route (commonly it's identifier) is set.
        attrs[:short_name]  = route.name.split.first if route.short_name.empty?
        attrs[:stations]    = route.stops.map do |stop_id|
          @station_key.call(api.stops.get(stop_id))
        end
        [@route_key.call(route), attrs]
      end.to_h
    end
  end

  register_source :doublemap, Shark::Route, RouteSource
end
