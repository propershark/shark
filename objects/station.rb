module Shark
  class Station < Object
    # [Integer] The identifying code for this station
    attribute :code
    # [String] The (often) humanized name for this station
    attribute :name
    # [String] The name of this route used on maps and signs to quickly
    # identify it
    attribute :stop_code
    # [String] The quick summary of what/where this station services
    attribute :description
    # [Float] The latitudinal position of this station
    attribute :latitude
    # [Float] The longitudinal position of this station
    attribute :longitude

    # While stations can be uniquely identified by their code, the code is not
    # platform agnostic and may vary across different information providers.
    # Thus, the short_name of the route is used as the primary attribute.
    primary_attribute :stop_code
  end
end
