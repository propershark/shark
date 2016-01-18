module CityBus
  class Vehicle < Resource
    class << self
      def vehicle route_id
        options = {
          body: {
            routeId: route_id
          }.to_json
        }
        # ask_for('/GetRoutePatterns', options)
      end
    end
  end
end
