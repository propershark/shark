module Shark
  module Schemable
    # A simple Schema DSL for configuring configurations.
    #
    # It includes methods for specifying optional and required properties,
    # each with potential type requirements and aliases for custom values.
    class Schema
      # The set of `Property`s that have been defined for the context.
      attr_accessor :properties

      # Create a new Schema instance, encapsulating a set of properties and
      # expectations for an Object.
      def initialize
        @properties = []
      end

      # Define a generic new property. `default` sets the default value of the
      # property, and `required` sets whether the property is required to be
      # present in the context. If given, `&block` will be instance-evaluated
      # on the new Property, such that any other parameters can be applied.
      def property name, type: BasicObject, default: nil, required: false, &block
        new_property = Property.new(name, type: type, default: default, required: required)
        new_property.instance_eval(&block) if block_given?
        properties << new_property
      end

      # Define an optional property for the configuration.
      def optional name, default: nil, &block
        property(name, default: default, required: false, &block)
      end

      # Define a required property for the configuration.
      def required name, default: nil, &block
        property(name, default: default, required: true, &block)
      end
    end
  end
end
