module Shark
  class Vehicle < Object
    # [Integer] The identifying code for this vehicle
    attribute :code
    # [String] The (often) humanized name for this vehicle
    attribute :name
    # [Float] The latitudinal position of this vehicle
    attribute :latitude
    # [Float] The longitudinal position of this vehicle
    attribute :longitude
    # [Integer] The number of passengers that this vehicle can carry at any
    # given time
    attribute :capacity
    # [Integer] The number of passengers currently onboard this vehicle
    attribute :onboard
    # [Float] The fullness of the vehicle expressed as a percentage in the
    # range [0-1]
    attribute :saturation
    # [String] The last stop that this vehicle departed from
    # NOTE: Only the identifier will be stored. If more information is needed,
    # a lookup must be performed on the storage adapter.
    attribute :last_station
    # [String] The next stop that this vehicle will arrive at
    # NOTE: Only the identifier will be stored. If more information is needed,
    # a lookup must be performed on the storage adapter.
    attribute :next_station
    # [String] The route that this vehicle is currently traveling on
    # NOTE: Only the identifier will be stored. If more information is needed,
    # a lookup must be performed on the storage adapter.
    attribute :route
    # [Integer] The amount of time by which this vehicle currently differs from
    # the schedule it is following (determined by `route`), stored as an
    # integral number of seconds
    attribute :schedule_delta
    # [Float] The directional heading of this vehicle in the range [0-360)
    attribute :heading
    # [Float] The speed that the vehicle is currently travelling at
    # TODO: determine unit of speed (mph, mps, kph, etc)
    attribute :speed

    # Vehicles should be uniquely indentifiable by their name.
    primary_attribute :name
  end
end
