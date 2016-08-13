class String
  # Returns true when `self` is a String that could be used as an Object
  # identifier.
  #
  # Identifiers are in the form "(xxxx.)*xxxx", where "xxxx" is a series of one
  # or more word characters.
  #
  # Example:
  #   "stations.BUS776W".identifier?          => true
  #   "citybus.vehicles.4002".identifier?     => true
  #   "one_string".identifier?                => false
  #   "citybus.vehicle set.4002".identifier?  => false
  def identifier?
    (/(\w+\.)*\w+/ =~ self) != nil
  end
end
