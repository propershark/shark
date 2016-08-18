require_relative 'schema'

module Shark
  class Configuration
    # Initialize a new configuration, optionally providing a schema to be
    # validated against.
    def initialize schema: nil
      @__schema = schema || ::Shark::Configurable::Schema.new
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
    def __validate!
      @__schema.properties.each do |property|
        # The accessor method with the property's name will only be defined if
        # it was given a value, so `respond_to?` can be used to determine
        # whether it was given.
        property_was_given = respond_to?(property.name)
        # If the property is required but was not given, then the configuration
        # does not meet the schema's requirements, so return false.
        return false if property.required? && !property_was_given
        # Fetch the value of the property that was given in the configuration.
        # If the property was not given, use the property's default value.
        given_value = property_was_given ? send(property.name) : property.default
        # Assign the resolved value as the value in the configuration.
        send("#{property.name}=", property.transform_value(given_value))
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
