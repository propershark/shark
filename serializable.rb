module Shark
  module Serializable
    # Because object associations are stored as identifiers, embedding them
    # requires looking up their actual value in the storage adapter.
    def lookup_object identifier
      Storage.adapter.find(identifier)
    end

    # Interpret the current configuration for this Object and return a
    # normalized version, with all options converted to their actual meaning
    # (i.e., convert `nil` to a blank array for `embedded_objects`, etc.).
    def normalized_configuration
      # To avoid regenerating the same normalization, return the previously-
      # generated normalization. Otherwise, perform the normalization.
      return @normalized_configuration if @last_normalized_configuration == configuration

      # Remember which configuration is being normalized for next time
      @last_normalized_configuration = configuration
      # Duplicate the configuration and apply changes to the duplicate
      @normalized_configuration = configuration.dup.tap do |config|
        config.serialized_attributes = begin
          case config.serialized_attributes
            # `:all` will include all attributes of the Object
            when :all   then self.class.attributes || []
            # A nil value will include no attributes
            when nil    then []
            # An array value will include only those attributes
            when Array  then config.serialized_attributes
          # Always include the object identifier in the list of attributes
          end | [:identifier]
        end
        config.embedded_objects = begin
          case config.embedded_objects
          # `:all` will embed all objects
          when :all     then self.class.attributes || []
          # A nil value will never embed objects
          when nil      then []
          # An array value will embed only those objects
          when Array    then config.embedded_objects
          end
        end
        config.embed_associated_objects = begin
          case config.embed_associated_objects
          when true   then self.associated_objects.keys
          when false  then []
          when Array  then config.embed_associated_objects
          end
        end
        config.nested_embedded_objects = begin
          case config.nested_embedded_objects
          # `:all` will embed all objects
          when :all   then self.class.attributes || []
          # A nil value will never embed objects
          when nil    then []
          # An array value will embed only those objects
          when Array  then config.nested_embedded_objects
          end
        end
        config.nested_serialized_attributes = begin
          case config.nested_serialized_attributes
            # `:all` will include all attributes of the Object
            when :all   then self.class.attributes || []
            # A nil value will include no attributes
            when nil    then []
            # An array value will include only those attributes
            when Array  then config.nested_serialized_attributes
          # Always include the object identifier in the list of attributes
          end | [:identifier]
        end
        config.embed_nested_associated_objects = begin
          case config.embed_nested_associated_objects
          when true   then self.associated_objects.keys
          when false  then []
          when Array  then config.embed_nested_associated_objects
          end
        end
      end
      @normalized_configuration
    end

    # Return the serialization of the Object with the given identifier. If the
    # Object does not exist, return the identifier string.
    #
    # If `nested` is true, the nested serialization will be returned instead.
    def serialization_for_identifier identifier, nested: false
      object = lookup_object(identifier)
      object ? object.to_h(nested: nested) : identifier
    end

    # Return true if the given Object attribute should be embedded in the
    # serialization of the Object, based on the configuration and the
    # given context.
    def should_embed_object object_name, nested: false
      if nested
        normalized_configuration.nested_embedded_objects.include?(object_name)
      else
        normalized_configuration.embedded_objects.include?(object_name)
      end
    end

    # Return the serialized form of the given attribute.
    # For simple types like String and Numeric, this will do nothing.
    # For container types like Array and Hash, each element they contain will
    # be serialized individually.
    # For Shark::Object instances, they will be serialized as nested embeds,
    # according to their configuration and the configuration of this Object.
    def serialize_attribute name, attribute, nested: false
      case attribute
      # Iteratively serialize container types
      when Array
        attribute.map{ |element| serialize_attribute(name, element, nested: nested) }
      when Hash
        attribute.map{ |key, val| [key, serialize_attribute(name, val, nested: nested)] }.to_h
      # Strings should check if they are identifiers (but not this Object's
      # identifier). If so, follow the configuration options for embedding.
      # Otherwise, just pass the string through.
      when String
        if attribute.identifier? && attribute != self.identifier
          if should_embed_object(name, nested: nested)
            serialization_for_identifier(attribute, nested: true)
          else
            attribute
          end
        else
          attribute
        end
      # Everything else gets passed through
      else
        attribute
      end
    end

    # Return a Hash representing the serialized version of `associated_objects`
    # for the Object.
    # The hash contents are set by `configuration.embed_associated_objects`.
    # If the value is false, this method will return the unmodified
    # `associated_objects` hash.
    def serialized_associated_objects
      associated_objects.map do |klass, set|
        if normalized_configuration.embed_associated_objects.include?(klass)
          [klass, set.map{ |ident| serialization_for_identifier(ident, nested: true) }]
        else
          [klass, set.to_a]
        end
      end.to_h
    end


    # Return a Hash representation (serialization) of this Object.
    def to_h nested: false
      # Determine the set of attributes to include in the serialization
      attribute_list = if nested
        normalized_configuration.nested_serialized_attributes
      else
        normalized_configuration.serialized_attributes
      end
      # Create a hash including all of the requested attributes
      hash = attribute_list.each_with_object({}) do |name, h|
        h[name] = serialize_attribute(name, send(name), nested: nested)
      end
      # Only embed associated objects on top level objects, or those which
      # specify it in their configuration.
      # TODO: this currently ignores `configuration.embed_nested_associated_objects`.
      hash[:associated_objects] = serialized_associated_objects if !nested
      hash
    end

    # Create a JSON representation of this Object by creating the Hash and
    # calling `to_json` on it.
    def to_json opts={}
      to_h.to_json(opts)
    end
  end
end
