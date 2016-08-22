module Shark
  module Schemable
    # A representation of a single property in a Configuration.
    #
    # Properties can be either required or optional, provide default values
    # used when the property is not explicitly given by a user, and can be
    # given custom value aliases that will be converted when the configuration
    # is applied.
    class Property
      # The name of this property, given as a symbol
      attr_accessor :name
      # The expected type of this property
      attr_accessor :type
      # The default value that this property will take on. If not set, this
      # will default to nil.
      attr_accessor :default
      # Whether this property is required to be explicitly set on an object.
      attr_accessor :required
      alias_method :required?, :required
      # Whether this property can be set to nil.
      attr_accessor :nilable
      alias_method :nilable?, :nilable
      # The set of value aliases that this property understands and can
      # transform.
      attr_accessor :value_aliases

      # Create a new property with the given name and default value.
      def initialize name, type: BasicObject, default: nil, required: false, nilable: false
        @name           = name
        @type           = type
        @default        = default
        @required       = required
        @nilable        = nilable
        @value_aliases  = Hash.new
      end

      # Define one or more value aliases. `aliases` is the possible values
      # given in the configuration, which will be transformed to `real_value`
      # when the configuration is validated.
      def value_alias *aliases, real_value:
        aliases.each do |name|
          value_aliases[name] = real_value
        end
      end

      # Return the real value of the given value, as determined by any entries
      # in the `value_aliases` hash. If no alias is given, return the original
      # value.
      # `context` is the object on which the configuration is being applied,
      # and will be used as the receiver for any proc-like values.
      def transform_value value, context:
        # Resolve the real value in case of aliases
        value = value_aliases[value] || value
        # Resolve callable values to get the actual value based on the context.
        value = context.instance_exec(&value) if value.respond_to?(:call)
        # Return the actual value
        value
      end
    end
  end
end
