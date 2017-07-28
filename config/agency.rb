# Include middleware classes and their configurations
require_relative './transport'
require_relative './conductor'
require_relative './validator'
require_relative './normalizer'

# Include configuration for Sources
require_relative 'bart_source'

# Include miscellaneous configuration files
require_relative './serialization'

# General agency configuration
Shark::Agency.configure do |agency|
  # Create a manager for Route objects
  agency.use_manager :route_manager do |manager|
    manager.object_type       = Shark::Route
    manager.update_frequency  = '4h'

    manager.source_from :bart
  end

  # Create a manager for Station objects
  agency.use_manager :station_manager do |manager|
    manager.object_type       = Shark::Station
    manager.update_frequency  = '1d'

    manager.source_from :bart
  end

  agency.use_middleware Normalizer
  agency.use_middleware Validator
  agency.use_middleware Conductor
  agency.use_middleware Transport
end
