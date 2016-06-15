module Shark
  class Station < Object
    # The identifying code for this station
    attribute :code
    # The (often) humanized name for this station
    attribute :name
    # The name of this route used on maps and signs to quickly identify it
    attribute :short_name
    # The quick summary of what/where this station services
    attribute :description
    # The latitudinal position of this station
    attribute :latitude
    # The longitudinal position of this station
    attribute :longitude
  end
end
