module Shark
  module Schemable
    # A simple Schema DSL for configuring configurations.
    #
    # It includes methods for specifying optional and required properties,
    # each with potential type requirements and aliases for custom values.
    class Schema
      # The set of `Property`s that have been defined for this schema.
      attr_accessor :properties
      # A simple set of options for this schema.
      attr_accessor :options


      DEFAULT_OPTIONS = {
        # Enforce property types when validating an object
        enforce_types: true
      }.freeze


      # Create a new Schema instance, encapsulating a set of properties and
      # expectations for an Object.
      # `options` is a hash of options that change the behavior of this schema.
      def initialize **options
        @properties = []
        @options = DEFAULT_OPTIONS.merge(options)
      end


      # Define a generic new property. `default` sets the default value of the
      # property, and `required` sets whether the property is required to be
      # present in the context. If given, `&block` will be instance-evaluated
      # on the new Property, such that any other parameters can be applied.
      def property name, **options, &block
        new_property = Property.new(name, **options)
        new_property.instance_eval(&block) if block_given?
        properties << new_property
      end

      # Define an optional property for the configuration.
      def optional name, **options, &block
        property(name, **options, &block)
      end

      # Define a required property for the configuration.
      def required name, **options, &block
        property(name, **options, &block)
      end


      # Determine whether the given object meets the expectations of this
      # schema by validating each property that has been defined.
      def validate object, alias_context: nil, transform: true
        # Transform the object to resolve any aliases that could affect the
        # validity of this object.
        self.transform(object, alias_context: alias_context) if transform
        properties.each do |prop|
          # True if the property is available on the object
          prop_exists     = object.respond_to?(prop.name)
          # True if the property has been given a value on the object
          prop_is_defined = object.instance_variable_defined?("@#{prop.name}")
          # Required properties must both exist and be defined
          if prop.required?
            return false unless prop_exists and prop_is_defined
          end

          # If `enforce_types` is set, ensure the type of the property matches
          # what is expected.
          if options[:enforce_types]
            given_value = prop_is_defined ? object.send(prop.name) : prop.default
            # Only enforce the type if the property exists and/or is required.
            if prop_is_defined || prop.required?
              # Ensure that the property's type matches what is expected.
              return false unless type_matches?(given_value, prop.type, nilable: prop.nilable?)
            end
          end
        end
        # If the requirements of all of the properties were met, then the
        # configuration is valid.
        self
      end

      # Perform any transformations that properties of this schema define.
      # `alias_context` is the object by which value aliases will be resolved.
      def transform object, alias_context: nil
        # By default, use the given object as the alias context
        alias_context ||= object
        properties.each do |prop|
          # Determine if the property currently has a value on the object
          prop_is_defined = object.instance_variable_defined?("@#{prop.name}")
          # If the property is required, but was not given, skip the property,
          # as transforming it may mask validation errors.
          next if prop.required? and !prop_is_defined
          # Fetch the current value of the property from the object.
          # If it was not defined, assume the default value for the property.
          given_value = prop_is_defined ? object.send(prop.name) : prop.default
          # Transform the value based on the property's definition
          transformed_value = prop.transform_value(given_value, context: alias_context)
          object.send("#{prop.name}=", transformed_value)
        end
        self
      end

      private
        # Return whether the given value fits the given type expectation.
        def type_matches? value, type, nilable: false
          return true if nilable and value.nil?
          case type
          # Array | Array[]       -> array with values of any type
          # Array[String]         -> array of Strings
          # Array[Float, String]  -> two-element array of Float and String
          # Array[[Float, Float]] -> array of [Float, Float] pairs
          when Array
            if value.is_a? Array
              if value.size > 0
                case type.size
                when 0 then true
                when 1
                  value.all?{ |val| type_matches?(val, type.first) }
                else
                  value.zip(type).all?{ |val, type| type_matches?(val, type) }
                end
              else
                true
              end
            else
              false
            end
          else
            value.is_a? type
          end
        end
    end
  end
end
