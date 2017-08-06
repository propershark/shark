module Shark
  class Station < Object
    self.version = '0.1.0'

    # [Integer] The identifying code for this station
    attribute :code,            type: String,  nilable: true
    # [String] The (often) humanized name for this station
    attribute :name,            type: String
    # [String] The name of this route used on maps and signs to quickly
    # identify it
    attribute :stop_code,       type: String
    # [String] The quick summary of what/where this station services
    attribute :description,     type: String,   nilable: true
    # [Float] The latitudinal position of this station
    attribute :latitude,        type: Float
    # [Float] The longitudinal position of this station
    attribute :longitude,       type: Float

    # While stations can be uniquely identified by their code, the code is not
    # platform agnostic and may vary across different information providers.
    # Thus, the short_name of the route is used as the primary attribute.
    primary_attribute :stop_code
  end
end
