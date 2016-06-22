require 'httparty'
require 'json'

# TODO:
# Technically, this could be generalized to "module TripSpark", as they service
# many different agencies across the country with the same software setup.
#
# Consider generalizing to work with different agencies.
module CityBus
  class Source
    # The relative URL of the endpoint used to feed this source.
    attr_accessor :endpoint
    # The name of the attribute used to index the data elements maintained by
    # this source.
    attr_accessor :key
    # The data maintained by this source, stored as a hash, indexed by the
    # primary key attribute given by `key`.
    attr_accessor :data

    # The base url for the citybus "API". Using HTTPS causes requests to take
    # longer than 5 seconds, which means the data would be stale before it had
    # event been received.
    API_BASE = "http://bus.gocitybus.com/RouteMap"

    def initialize endpoint:, key:
      @endpoint = endpoint
      @key      = key
      @data     = {}
    end

    # Perform a GET request to the URL formed by joining the API_BASE and
    # endpoint fields. Return the parsed body of the response.
    def get
      url = "#{API_BASE}/#{@endpoint}"
      HTTParty.get(url).parsed_response
    end

    # Perform a POST request to the URL formed by joining the API_BASE and
    # endpoint fields, passing the optional `params` as form data. Return
    # the parsed body of the response.
    def post params={}
      url = "#{API_BASE}/#{@endpoint}"
      res = HTTParty.post(url, body: params)
      JSON.parse(res.body)
    end
  end
end

require_relative 'citybus/route'
require_relative 'citybus/station'
require_relative 'citybus/vehicle'
