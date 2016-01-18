module CityBus
  class Pattern < Resource
    class << self
      def pattern route_id
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
