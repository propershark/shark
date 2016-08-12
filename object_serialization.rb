module Shark
  module ObjectSerialization
    # Because object associations are stored as identifiers, embedding them
    # requires looking up their actual value in the storage adapter.
    def lookup_object identifier
      Storage.adapter.find(identifier)
    end

    # Return an array of names of attributes that should be included in the
    # serialization of the Object.
    #
    # This list is determined by `configuration.embedded_attributes`, but will
    # always include the identifying attribute.
    def attributes_to_embed
      embedded_attributes = case configuration.embedded_attributes
      # A True value will embed all attributes
      when TrueClass
        self.class.attributes
      # A false value will embed no attributes
      when FalseClass
        []
      # An array value will embed only those attributes
      when Array
        configuration.embedded_attributes
      end
      # Always include the object identifier in the list of attributes
      embedded_attributes | [self.class.identifying_attribute]
    end

    # Same as `attributes_to_embed`, but return the attributes that should be
    # included when the Object is nested within another Object.
    #
    # The list is determined by `configuration.nested_embedded_attributes`, and
    # will always include the identifying attribute.
    def nested_attributes_to_embed
      embedded_attributes = case configuration.nested_embedded_attributes
      # A True value will embed all attributes
      when TrueClass
        self.class.attributes
      # A false value will embed no attributes
      when FalseClass
        []
      # An array value will embed only those attributes
      when Array
        configuration.nested_embedded_attributes
      end
      # Always include the object identifier in the list of attributes
      embedded_attributes | [self.class.identifying_attribute]
    end

    # Return the serialization of the Object with the given identifier. If the
    # Object does not exist, return the identifier string.
    #
    # If `nested` is true, the nested serialization will be returned instead.
    def serialization_for_identifier identifier, nested: false
      object = lookup_object(identifier)
      object ? object.to_h(nested: nested) : identifier
    end

    # Return a Hash representing the serialized version of `associated_objects`
    # for the Object.
    # The hash contents are set by `configuration.embed_associated_objects`.
    # If the value is false, this method will return the unmodified
    # `associated_objects` hash.
    def serialized_associated_objects
      associated_objects.map do |klass, set|
        # Determine how to embed each set based on the configuration
        case configuration.embed_associated_objects
        # A True value will embed all associated objects
        when TrueClass
          [klass, set.map{ |ident| serialization_for_identifier(ident, nested: true) }]
        # A False value will leave `associated_objects` as-is, but will convert
        # the Set values to arrays for serialization by `to_json`.
        when FalseClass
          [klass, set.to_a]
        # An array value will only embed objects of the given types
        when Array
          if configuration.embed_associated_objects.include? klass
            [klass, set.map{ |ident| serialization_for_identifier(ident, nested: true) }]
          else
            [klass, set.to_a]
          end
        else
          [klass, set.to_a]
        end
      end.to_h
    end


    # Return the serialization of an Object as it should appear when nested
    # within another Object.
    #
    # The contents of the serialization are determined by the option
    # `configuration.nested_embedded_attributes`.
    def nested_serialization
      to_h(nested: true)
    end

    # Return a Hash representation (serialization) of this Object.
    def to_h nested: false
      # Determine the set of attributes to include in the serialization
      attribute_list = nested ? nested_attributes_to_embed : attributes_to_embed
      # Create a hash including all of the requested attributes
      hash = attribute_list.each_with_object({}) do |name, h|
        h[name] = instance_variable_get("@#{name}");
      end
      # Only embed associated objects on top level objects, or those which
      # specify it in their configuration.
      if !nested || (nested && configuration.embed_nested_associated_objects)
        hash[:associated_objects] = serialized_associated_objects
      end
      hash
    end

    # Create a JSON representation of this Object by creating the Hash and
    # calling `to_json` on it.
    def to_json opts={}
      to_h.to_json(opts)
    end
  end
end
