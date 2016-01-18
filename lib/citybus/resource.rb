module CityBus
  class Resource
    class << self
      # The default options for a request to the CityBus API.
      # The only thing needed here is setting the content type to
      # application/json. Otherwise, the API will respond with the full HTML
      # page, which is inefficient to say the least.
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
end
