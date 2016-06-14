module Shark
  # Wrapping class for objects to allow hash-based initialization and updating
  # of attributes
  class Object
    def initialize **args
      self.update(args)
    end

    def update **args
      args.keys.each{ |name| instance_variable_set("@"+name.to_s, args[name]) }
    end
  end
end
