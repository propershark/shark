module DoubleMap
  class RouteSource < Source
    # A key-value map of attributes on the Route class to entries in the
    # source data
    ATTRIBUTE_MAP = {
      code: 'id',
      name: 'name',
      short_name: 'short_name',
      description: 'description',
      color: 'color',
      path: 'path',
      stations: 'stops'
    }

    # Update the local cache of data to prepare for an `update` cycle
    def refresh
      @data = self.get.map do |route|
        # Convert the route's path from a flat list into pairs.
        route['path'] = route['path'].each_slice(2).to_a
        route['short_name'] = route['name'].split.first if route['short_name'].empty?
        mapped_info = ATTRIBUTE_MAP.each_with_object({}) do |(prop, name), h|
          h[prop] = route[name]
        end
        [route[@key], mapped_info]
      end.to_h
    end

    # Iterate through the local cache of data, activating and updating objects
    # on the given manager as they come up
    def update manager
      @data.each do |key, info|
        # If the route already exists in the manager, load it. Otherwise,
        # create a new one.
        route = manager.find_or_new(key)
        # Update the information on the Route object to match the current
        # data from the source
        route.assign(info)
        # Ensure that the route is active in the manager
        manager.activate(route)
      end
    end
  end
end
