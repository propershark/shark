module Shark
  class Route < Object
    # The identifying code for this route
    attribute :code
    # The (often) humanized name for this route
    attribute :name
    # The name of this route used on maps and signs to quickly identify it
    attribute :short_name
    # The quick summary of what/where this route services
    attribute :description
    # The hexadecimal color used to shade this route on maps
    attribute :color
    # The geo-spatial path that this route takes, stored as [lat, lon] pairs
    attribute :path
    # The ordered list of stops that this route touches
    attribute :stops

    # While routes can be uniquely identified by their code, the code is not
    # platform agnostic and may vary across different information providers.
    # Thus, the short_name of the route is used as the primary attribute.
    primary_attribute :short_name
  end
end
