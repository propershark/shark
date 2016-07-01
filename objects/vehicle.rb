module Shark
  class Vehicle < Object
    # The identifying code for this vehicle
    attribute :code
    # The (often) humanized name for this vehicle
    attribute :name
    # The latitudinal position of this vehicle
    attribute :latitude
    # The longitudinal position of this vehicle
    attribute :longitude
    # The number of passengers that this vehicle can carry at any given time
    attribute :capacity
    # The number of passengers currently onboard this vehicle
    attribute :onboard
    # The fullness of the vehicle expressed as a percentage
    attribute :saturation
    # The last stop that this vehicle departed from
    attribute :last_station
    # The next stop that this vehicle will arrive at
    attribute :next_station
    # The route that this vehicle is currently traveling on
    attribute :route
    # The amount of time by which this vehicle currently differs from the
    # schedule it is following (determined by `route`)
    attribute :schedule_delta
    # The directional heading of this vehicle
    attribute :heading
    # The speed that the vehicle is currently travelling at
    # TODO: determine unit of speed (mph, mps, kph, etc)
    attribute :speed

    # Vehicles should be uniquely indentifiable by their name.
    primary_attribute :name
  end
end
