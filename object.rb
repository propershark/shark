module Shark
  # Wrapping class for objects to allow hash-based initialization and updating
  # of attributes.
  class Object
    # Attributes defined with the `attribute` macro are:
    #   - Assignable and initializable via Hash arguments.
    #   - Included in the Hash representation of the object.
    class << self
      attr_accessor :attributes
      def attribute *args
        (@attributes ||= []).concat(args)
        attr_accessor(*args)
      end
    end

    # Instantiate a new Object, initializing the attributes provided. Other
    # attributes will not be given a value.
    def initialize args={}
      assign(args)
    end

    # For every attribute given in `args`, assign it's value on this Object to
    # the provided value.
    def assign args={}
      args.keys.each{ |name| instance_variable_set("@#{name}", args[name]) }
    end

    # Return a Hash representation of this Object containing all attributes
    # defined on it through `attr_accessor`.
    def to_h
      self.class.attributes.inject({}){ |h, name| h[name] = instance_variable_get("@#{name}"); h }
    end
  end
end
