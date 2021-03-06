module Shark
  module Source
    # The NormalSource class defines the interface that all Sources must
    # implement to work smoothly with the rest of the system, as well as a few
    # utilities that sources commonly use, such as class- and instance-level
    # configuration methods.
    class NormalSource
      class << self
        include Configurable
      end

      include Configurable
      inherit_configuration_from self

      # Instantiate a new Source object, with any additionally configuration
      # for this Source instance provided as a Hash.
      #
      # Ideally, all configuration would be done through class configuration,
      # but there may be some cases where instance-specific configuration can
      # be useful, such as sharding across multiple managers.
      def initialize instance_config={}
        # Create a copy of the class configuration, so as not to modify it
        # while applying the instance-level configuration for this Source.
        configuration.__apply(instance_config)
        read_configuration
        # A generic hash of information that will persist along with this
        # Source. Commonly used to store information in `refresh` that will be
        # used in `update`.
        @data = {}
      end

      # Provide a hook for classes to optionally read/apply configurations. By
      # default, this method does nothing, and is simply provided for
      # convenience.
      # When overridden by a class, this method should also ensure that all
      # necessary configuration options are provided.
      def read_configuration
      end


      # Poll whatever provides information for this Source to refresh the local
      # data set. Often, this gets stored in the `@data` hash.
      def refresh
        raise "Source classes must implement their own `refresh` method"
      end

      # Apply the new information in `@data` to their respective objects in the
      # object manager that gets passed in.
      #
      # This class provides a default behavior for this method, where each key
      # in the `@data` hash is looked up on the manager (if it does not exist,
      # a new object of the manager's type is created). Then, the information
      # for the current key is applied to that object through `.assign`.
      # Finally, the object is activated on the manager.
      def update manager
        @data.each do |key, info|
          object = manager.find_or_new(key)
          object.assign(info)
          manager.activate(object)
        end
      end
    end
  end
end
