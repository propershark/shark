# Each Object class has some specific serialization options (mainly dealing
# with which attributes get embedded). Those specializations are given here.

Shark::Route.configure do |config|
  # Only associated stations should be embedded on Routes. Embedding vehicles
  # could lead to a cyclical structure, and is generally unnecessary.
  config.embed_associated_objects = [Shark::Station]
  # These attributes are generally what clients need to know about a route when
  # looking at either Stations or Vehicles (where a Route would be nested).
  config.nested_serialized_attributes = [:name, :short_name, :color]
end

Shark::Station.configure do |config|
  # Station embeds are minimal. Generally, only an identifier and name are
  # needed.
  config.nested_serialized_attributes = [:name]
end

Shark::Vehicle.configure do |config|
  # This could potentially be expanded to include most information about a
  # Vehicle (capacity, saturation, speed, last/next stations), but clients
  # can easily subscribe to the vehicle for this information, and it would
  # just be redundant here.
  config.nested_serialized_attributes = [:name, :latitude, :longitude]
end
