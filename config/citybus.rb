require_relative '../middlewares/transport'
require_relative '../middlewares/conductor'

# Configuration for all DoubleMap source objects
DoubleMapSource.configure do |doublemap|
  doublemap.agency      = :citybus
  doublemap.route_key   = :short_name
  # DoubleMap does not have :stop_code as part of it's schema, but it is useful
  # for creating shorter channel names. This lambda essentially patches
  # stop_code onto DoubleMap::Station objects.
  doublemap.station_key = ->(station){ station.name[/BUS\w*|TEMP\w*/].chomp }
  doublemap.vehicle_key = :name
end


# # Configuration for all CityBus source objects
# CityBus.configure do |citybus|
#   citybus.route_key     = :short_name
#   citybus.station_key   = :stop_code
#   citybus.vehicle_key   = :name
# end


# General agency configuration
Shark::Agency.configure do |agency|
  # Create a manager for Route objects
  agency.use_manager :route_manager do |manager|
    manager.object_type       = Shark::Route
    manager.update_frequency  = '4h'
    manager.namespace         = 'routes'

    # Route information comes from DoubleMap and CityBus
    manager.source_from :doublemap
    manager.source_from :citybus
  end

  # Create a manager for Station objects
  agency.use_manager :station_manager do |manager|
    manager.object_type       = Shark::Station
    manager.update_frequency  = '1d'
    manager.namespace         = 'stations'

    # Station information only comes from DoubleMap, since CityBus does not
    # provide any useful information that can not be found in DoubleMap.
    manager.source_from :doublemap
  end

  # Create a manager for Vehicle objects
  agency.use_manager :vehicle_manager do |manager|
    manager.object_type       = Shark::Vehicle
    manager.update_frequency  = '2s'
    manager.namespace         = 'vehicles'

    # Vehicle information comes from DoubleMap and CityBus
    manager.source_from :doublemap
    manager.source_from :citybus
  end


  agency.use_middleware Transport, config_file: 'config/transport.yml'
  agency.use_middleware Conductor, vehicle_namespace: 'vehicles.'
end
