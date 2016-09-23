# Include middleware classes and their configurations
require_relative './transport'
require_relative './conductor'
require_relative './validator'
require_relative './normalizer'

# Include configuration for Sources
require_relative 'doublemap_source'
require_relative 'tripspark_source'

# Include miscellaneous configuration files
require_relative './serialization'

# General agency configuration
Shark::Agency.configure do |agency|
  # Create a manager for Route objects
  agency.use_manager :route_manager do |manager|
    manager.object_type       = Shark::Route
    manager.update_frequency  = '4h'

    # Route information comes from DoubleMap and CityBus
    manager.source_from :doublemap
    manager.source_from :tripspark
  end

  # Create a manager for Station objects
  agency.use_manager :station_manager do |manager|
    manager.object_type       = Shark::Station
    manager.update_frequency  = '1d'

    # Station information only comes from DoubleMap, since CityBus does not
    # provide any useful information that can not be found in DoubleMap.
    manager.source_from :doublemap
  end

  # Create a manager for Vehicle objects
  agency.use_manager :vehicle_manager do |manager|
    manager.object_type       = Shark::Vehicle
    manager.update_frequency  = '2s'

    # Vehicle information comes from DoubleMap and CityBus
    manager.source_from :doublemap
    manager.source_from :tripspark
  end


  agency.use_middleware Normalizer
  agency.use_middleware Validator
  agency.use_middleware Conductor
  agency.use_middleware Transport
end
