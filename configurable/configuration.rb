module Shark
  class Configuration
    include Schemable

    # Initialize a new configuration, optionally providing a schema to be
    # validated against.
    def initialize schema: nil
      self.schema = schema
    end

    # For any property that gets defined on this configuration object, add it
    # to a hash of options.
    def method_missing sym_name, *args
      name = sym_name.to_s
      prop_name = name.sub("=","")
      # Define the reader and writer for this new property.
      self.class.module_eval{ attr_accessor prop_name }
      # If this was an assignment, perform it with the given argument.
      # If this was an access, call the accessor, which should return nil.
      (prop_name == name) ? send(prop_name) : send(name, args.first)
    end

    # Iterate the set of properties that are defined in this configuration's
    # schema, resolving any value aliases and ensuring this configuration
    # meets the schema's requirements.
    # `context` is the object on which the configuration is being applied, and
    # will be used by value aliases of properties to resolve values based on
    # that object.
    # By default, if the configuration does not meet the schema's requirements,
    # a ConfigurationError will be raised.
    def __validate! context, suppress_errors: false
      self.schema.properties.each do |property|
        # The instance variable with the property's name will only be defined
        # if it was given a value in the configuration, so
        # `instance_variable_defined?` can be used to determine whether it was
        # given.
        property_was_given = instance_variable_defined?("@#{property.name}")
        # If the property is required but was not given, then the configuration
        # does not meet the schema's requirements, so raise an error, or return
        # false if errors should be suppressed.
        if property.required? && !property_was_given
          # Return early if the error should be suppressed.
          return false if suppress_errors
          # Otherwise, raise a ConfigurationError, indicating which property
          # caused the failure.
          raise ConfigurationError, "`#{property.name}` was not given in the configuration of `#{context}`."
        end
        # Fetch the value of the property that was given in the configuration.
        # If the property was not given, use the property's default value.
        given_value = property_was_given ? send(property.name) : property.default
        # Assign the resolved value as the value in the configuration.
        send("#{property.name}=", property.transform_value(given_value, context: context))
      end
      # If the requirements of all of the properties were met, then the
      # configuration is valid. Following convention, return self.
      self
    end

    # Apply a given hash of configuration options to this object. Useful for
    # applying instance-level options to a class-level configuration.
    def __apply new_options
      new_options.each{ |name, value| send("#{name}=", value) }
      self
    end
  end
end
