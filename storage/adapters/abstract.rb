module Shark
  module Storage
    class AbstractAdapter
      # Locate a record by it's universally unique identifier. This consists of
      # the namespace of the object (routes, stations, vehicles, etc.) and the
      # identifier of that object (its primary attribute).
      def find identifier
        raise "Adapters must implement `find`"
      end

      # Create a new record in the data store with the given identifier as a key
      # and the given object as the value.
      def create identifier, object
        raise "Adapters must implement `create`"
      end

      # Replace the record with the given identifier with the new given object.
      def replace identifier, object
        raise "Adapters must implement `replace`"
      end

      # Remove the record with the given identifier from the data store.
      def remove identifier
        raise "Adapters must implement `remove`"
      end
    end
  end
end
