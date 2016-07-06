module Shark
  class Configuration
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

    # Apply a given hash of configuration options to this object. Useful for
    # applying instance-level options to a class-level configuration.
    def __apply new_options
      new_options.each{ |name, value| send("#{name}=", value) }
      self
    end
  end
end
