require 'httparty'

module DoubleMap
  class Source
    # The name of the agency providing information via doublemap. This should
    # match the subdomain used on doublemap.com
    attr_accessor :agency
    # The relative URL of the endpoint used to feed this source.
    attr_accessor :endpoint
    # The name of the attribute used to index the data elements maintained by
    # this source.
    attr_accessor :key
    # The data maintained by this source, stored as a hash, indexed by the
    # primary key attribute given by `key`.
    attr_accessor :data

    # The base url for the doublemap API.
    API_BASE = "doublemap.com/map/v2"

    def initialize agency:, endpoint:, key:
      @agency   = agency
      @endpoint = endpoint
      @key      = key
      @data     = {}
    end

    # Perform a GET request to the URL formed by joining the agency, API_BASE,
    # endpoint fields. Return the parsed body of the response.
    def get
      url = "https://#{@agency}.#{API_BASE}/#{@endpoint}"
      HTTParty.get(url).parsed_response
    end
  end
end
