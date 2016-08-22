module Shark
  class Vehicle < Object
    # [Integer] The identifying code for this vehicle
    attribute :code,            type: Integer,  nilable: true
    # [String] The (often) humanized name for this vehicle
    attribute :name,            type: String
    # [Float] The latitudinal position of this vehicle
    attribute :latitude,        type: Float
    # [Float] The longitudinal position of this vehicle
    attribute :longitude,       type: Float
    # [Integer] The number of passengers that this vehicle can carry at any
    # given time
    attribute :capacity,        type: Integer,  nilable: true
    # [Integer] The number of passengers currently onboard this vehicle
    attribute :onboard,         type: Integer,  nilable: true
    # [Float] The fullness of the vehicle expressed as a percentage in the
    # range [0-1]
    attribute :saturation,      type: Float,    nilable: true
    # [String] The last stop that this vehicle departed from
    # NOTE: Only the identifier will be stored. If more information is needed,
    # a lookup must be performed on the storage adapter.
    attribute :last_station,    type: String,   nilable: true
    # [String] The next stop that this vehicle will arrive at
    # NOTE: Only the identifier will be stored. If more information is needed,
    # a lookup must be performed on the storage adapter.
    attribute :next_station,    type: String,   nilable: true
    # [String] The route that this vehicle is currently traveling on
    # NOTE: Only the identifier will be stored. If more information is needed,
    # a lookup must be performed on the storage adapter.
    attribute :route,           type: String,   nilable: true
    # [Integer] The amount of time by which this vehicle currently differs from
    # the schedule it is following (determined by `route`), stored as an
    # integral number of seconds
    attribute :schedule_delta,  type: Integer,  nilable: true
    # [Float] The directional heading of this vehicle in the range [0-360)
    attribute :heading,         type: Float,    nilable: true
    # [Float] The speed that the vehicle is currently travelling at
    # TODO: determine unit of speed (mph, mps, kph, etc)
    attribute :speed,           type: Float,    nilable: true

    # Vehicles should be uniquely indentifiable by their name.
    primary_attribute :name
  end
end
