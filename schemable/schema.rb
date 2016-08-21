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


      # Determine whether the given object meets the expectations of this
      # schema by validating each property that has been defined.
      def validate object
        properties.each do |prop|
          # True if the property is available on the object
          prop_exists     = object.respond_to?(prop.name)
          # True if the property has been given a value on the object
          prop_is_defined = object.instance_variable_defined?("@#{prop.name}")
          # Required properties must both exist and be defined
          if prop.required?
            return false unless prop_exists and prop_is_defined
          end
        end
        # If the requirements of all of the properties were met, then the
        # configuration is valid.
        self
      end


      # Perform any transformations that properties of this schema define. This
      # method assumes that the given object has already been validated against
      # this schema.
      def transform object
        properties.each do |prop|
          # Fetch the current value of the property from the object.
          # If it was not defined, assume the default value for the property.
          prop_is_defined = object.instance_variable_defined?("@#{prop.name}")
          given_value = prop_is_defined ? object.send(prop.name) : prop.default
          # Transform the value based on the property's definition
          transformed_value = prop.transform_value(given_value, context: object)
          object.send("#{prop.name}=", transformed_value)
        end
        self
      end
    end
  end
end
