module CityBus
  class Stop < Resource
    class << self
      def stop route_id
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
