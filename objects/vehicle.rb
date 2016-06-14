module Shark
  class Vehicle < Object
    # The identifying code for this vehicle
    attr_accessor :code
    # The (often) humanized name for this vehicle
    attr_accessor :name
    # The latitudinal position of this vehicle
    attr_accessor :latitude
    # The longitudinal position of this vehicle
    attr_accessor :longitude
    # The number of passengers that this vehicle can carry at any given time
    attr_accessor :capacity
    # The number of passengers currently aboard this vehicle
    attr_accessor :passengers
    # The last stop that this vehicle departed from
    attr_accessor :last_stop
    # The next stop that this vehicle will arrive at
    attr_accessor :next_stop
    # The route that this vehicle is currently traveling on
    attr_accessor :route
    # The amount of time by which this vehicle currently differs from the
    # schedule it is following (determined by `route`)
    attr_accessor :schedule_delta
    # The directional heading of this vehicle
    attr_accessor :heading
  end
end
