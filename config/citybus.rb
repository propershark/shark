# Configuration for all DoubleMap source objects
DoubleMap.configure do |doublemap|
  doublemap.agency      = :citybus
  doublemap.route_key   = :short_name
  # DoubleMap does not have :stop_code as part of it's schema, but it is useful
  # for creating shorter channel names. This lambda essentially patches
  # stop_code onto DoubleMap::Station objects.
  doublemap.station_key = ->{ |station| station.name[/BUS\w*|TEMP\w*/].chomp }
  doublemap.vehicle_key = :name
end


# Configuration for all CityBus source objects
CityBus.configure do |citybus|
  citybus.route_key     = :short_name
  citybus.station_key   = :stop_code
  citybus.vehicle_key   = :name
end


# General agency configuration
Shark::Agency.configure do |agency|
  # Define the namespace prefixes to use when creating events for different
  # objects. Object identifiers will be prefixed with the namespace for their
  # type to create a universally-unique identifier. For example, using this
  # configuration, a Route with the identifier "1A", would have a universally-
  # unique identifier of "routes.1A".
  #
  # These are the default values for the namespaces, but are given here as an
  # example of how to use this configuration.
  agency.namespaces = {
    routes: 'routes.',
    stations: 'stations.',
    vehicles: 'vehicles.'
  }

  # Create a manager for Route objects
  agency.use_manager :route_manager do |manager|
    manager.object_type       = Route
    manager.update_frequency  = '4h'
    manager.namespace         = 'routes'

    # Route information comes from DoubleMap and CityBus
    manager.source_from :doublemap
    manager.source_from :citybus
  end

  # Create a manager for Station objects
  agency.use_manager :station_manager do |manager|
    manager.object_type       = Station
    manager.update_frequency  = '1d'
    manager.namespace         = 'stations'

    # Station information only comes from DoubleMap, since CityBus does not
    # provide any useful information that can not be found in DoubleMap.
    manager.source_from :doublemap
  end

  # Create a manager for Vehicle objects
  agency.use_manager :vehicle_manager do |manager|
    manager.object_type       = Vehicle
    manager.update_frequency  = '2s'
    manager.namespace         = 'vehicles'

    # Vehicle information comes from DoubleMap and CityBus
    manager.source_from :doublemap
    manager.source_from :citybus
  end


  agency.use_middleware Transport
  agency.use_middleware Conductor
end
