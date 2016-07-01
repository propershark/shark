module Shark
  module Storage
    # A Data Storage adapter for saving objects in memory. Useful for super-low
    # latency applications with relatively small datasets.
    class MemoryAdapter < AbstractAdapter
      def initialize configuration
        @storage = {}
      end

      # Locate a record by it's universally unique identifier. This consists of
      # the namespace of the object (routes, stations, vehicles, etc.) and the
      # identifier of that object (its primary attribute).
      def find identifier
        @storage[identifier]
      end

      # Create a new record in the data store with the given identifier as a key
      # and the given object as the value.
      def create identifier, object
        @storage[identifier] = object
      end

      # Replace the record with the given identifier with the new given object.
      def replace identifier, object
        create(identifier, object)
      end

      # Remove the record with the given identifier from the data store.
      def remove identifier
        @storage.delete(identifier)
      end
    end

    register_adapter :memory, MemoryAdapter
  end
end
