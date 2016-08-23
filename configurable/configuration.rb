module Shark
  class Configuration
    include Schemable

    # Initialize a new configuration, optionally providing a schema to be
    # validated against.
    def initialize schema: nil
      # If a schema was given, use that instead of the default
      self.schema = schema if schema
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
    def validate! context: self
      self.schema.validate(self, alias_context: context) ? self : false
    end

    # Apply a given hash of configuration options to this object. Useful for
    # applying instance-level options to a class-level configuration.
    def __apply new_options
      new_options.each{ |name, value| send("#{name}=", value) }
      self
    end
  end
end
