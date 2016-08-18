module Shark
  module Configurable
    def self.included(base)
      base.extend(ClassMethods)
    end

    # The full configuration instance used by the includer.
    attr_accessor :configuration

    # Return the current configuration object
    def configuration
      @configuration ||= configuration_type.new(schema: configuration_schema)
    end

    # Yield the configuration object so it can be modified through a block.
    # Unless `validate` is explicitly set to false, the configuration will be
    # validated after the block has returned.
    def configure validate: true, &block
      configuration.tap(&block)
      configuration.__validate! if validate
    end

    # Return the type to instantiate for the configuration object
    def configuration_type
      Configuration
    end

    # Configure the schema (properties, expectations, etc.) of the
    # configuration. If no block is given, simply return the current schema.
    def configuration_schema &block
      @schema ||= Schema.new
      @schema.instance_eval(&block) if block_given?
      @schema
    end


    module ClassMethods
      # A class macro to enable inheritance of configuration from another object.
      # Note that `type` must implement `.configuration` for this to succeed.
      def inherit_configuration_from type
        # Redefine `#configuration` to inherit from the given type instead of
        # creating a new Configuration object
        define_method(:configuration) do
          @configuration ||= type.configuration.dup
        end
      end

      # Define a custom Configuration class to use as the type of the
      # `configuration` instance.
      def use_configuration_type type
        define_method(:configuration_type){ type }
      end
    end
  end
end
