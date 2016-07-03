require_relative 'configuration'

module Shark
  module Configurable
    def self.included(base)
      base.extend(ClassMethods)
    end

    # The full configuration instance used by the includer.
    attr_accessor :configuration

    # Return the current configuration object
    def configuration
      @configuration ||= Configuration.new
    end

    # Yield the configuration object so it can be modified through a block.
    def configure
      yield configuration
      configuration
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
    end
  end
end
