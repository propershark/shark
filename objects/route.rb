module Shark
  class Route < Object
    # [Integer] The identifying code for this route
    attribute :code
    # [String] The (often) humanized name for this route
    attribute :name
    # [String] The name of this route used on maps and signs to quickly
    # identify it
    attribute :short_name
    # [String] The quick summary of what/where this route services
    attribute :description
    # [String] The hexadecimal color used to shade this route on maps. Includes
    # the leading hash character.
    attribute :color
    # [Array[Float, Float]] The geo-spatial path that this route takes, stored
    # as [lat, lon] pairs
    attribute :path
    # [Array[String]] The ordered list of Stations that this route touches.
    # NOTE: Only the identifier for each Station will be stored. If the rest of
    # their information is needed, a lookup must be performed on the storage
    # adapter.
    attribute :stations

    # While routes can be uniquely identified by their code, the code is not
    # platform agnostic and may vary across different information providers.
    # Thus, the short_name of the route is used as the primary attribute.
    primary_attribute :short_name
  end
end
