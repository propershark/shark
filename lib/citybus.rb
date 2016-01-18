require 'httparty'
require 'json'

# An interface to CityBus' real-time API. It's not documented anywhere
# accessible, so this module is entirely based on reverse-engineering through
# their online map, available at the URL in API_BASE in your browser.
module CityBus
  API_BASE = 'http://bus.gocitybus.com/Public/map.aspx'

  class << self
    def route route_id
      options = {
        body: {
          routeId: route_id
        }.to_json
      }
      ask_for('/GetRoutePatterns', options)
    end

    def vehicles route_id
      options = {
        body: {
          routeIdList: [route_id]
        }.to_json
      }
      ask_for('/GetVehicles', options)
    end

    def vehicle_info vehicle_id
      options = {
        body: {
          vehicleId: vehicle_id
        }.to_json
      }
      ask_for('/GetVehicleInfo', options)
    end

    BASE_OPTIONS = {
      headers: {
        'Content-Type' => 'application/json; charset=utf-8'
      }
    }

    def ask_for uri, options
        # Create the full request URL
        url = CityBus::API_BASE + uri
        # Merge the given options with the default values
        options = BASE_OPTIONS.merge options
        # Make the request to CityBus
        response = HTTParty.post(url, options)
        # If the response returned information, parse and return it.
        # CityBus puts the JSON response in a string (why?) under the key 'd'.
        return JSON.parse(response['d']) if response.has_key? 'd'
        # Otherwise, return nothing
        nil
      end
  end
end
