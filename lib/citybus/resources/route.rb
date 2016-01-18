module CityBus
  class Route < Resource
    class << self
      def route route_id
        options = {
          body: {
            routeId: route_id
          }.to_json
        }
        ask_for('/GetRoutePatterns', options)
      end
    end
  end
end
