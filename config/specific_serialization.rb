# Each Object class has some specific serialization options (mainly dealing
# with which attributes get embedded). Those specializations are given here.

Shark::Route.configure do |config|
  config.nested_embedded_attributes = [:name, :short_name, :color]
  config.embed_depth = 3
end

Shark::Station.configure do |config|
  config.nested_embedded_attributes = [:name]
end
