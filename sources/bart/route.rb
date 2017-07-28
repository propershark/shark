module BartSource
  class RouteSource < Source
    def refresh
      #api.flush_cache
      @data = api.routes.all
      .select{ |r| r.id % 2 == 1 }
      .lazy.map{ |r| api.routes.get r.id }.map do |route|
        attrs = @route_attributes.each_with_object({}) do |(prop, name), h|
          h[prop] = route.send(name)
        end

        attrs[:short_name] = @route_key.call(route)
        attrs[:itinerary] = route.config['station'].map do |stop_id|
          Shark::Station.identifier_for stop_id
        end

        ["routes."+@route_key.call(route), attrs]
      end
    end
  end

  register_source :bart, Shark::Route, RouteSource
end
