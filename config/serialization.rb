# Any instance of Shark::Object will inherit this configuration. If a subclass
# or specific instance wishes to change any of these options, it can override
# the specific options it needs through it's own `configure` block.
Shark::Object.configure do |config|
  ### Serialization ###

  # Set to true to embed all objects in a one-to-many association. For example:
  # when true, a Route will embed object information for each Station in its
  # `stations` attribute; when false, the attribute would be kept as a list of
  # identifiers.
  config.embed_has_many_associations = true

  # The number of levels through which object embedding will occur.
  # A value of 0 will perform no embedding on Objects.
  # A value of 1 will embed Objects that are direct attributes of an Object.
  # Values higher than 1 will embed further-nested Object attributes.
  config.embed_depth = 1


  # Specify the list of attributes to be included when serializing the object.
  # If set to `:all`, all attributes will be included. To limit which
  # attributes are included, use an array of attribute names.
  # Set to `nil` to not include any attributes in the serialization.
  #
  # The identifier for an object will always be included, regardless of the
  # value for this option.
  #
  # For example:
  #   config.serialized_attributes = [:name, :latitude, :longitude]
  #   config.serialized_attributes = nil
  config.serialized_attributes = :all

  # Specify the list of Objects to be embedded when serializing the object.
  # Embedding an Object attribute will transform the identifier that is stored
  # for an Object into a Hash of attributes for that Object (the contents of
  # which is determined by the `nested_serialized_attributes` and
  # `nested_embedded_objects` configuration options for that Object).
  #
  # If set to `:all`, all Object attributes will be embedded. To limit which
  # Objects are embedded, use an array of attribute names.
  # Set to `nil` to not embed any Objects in the serialization.
  #
  # For example:
  #   config.embedded_objects = :all
  #   config.embedded_objects = [:name, :latitude, :longitude]
  config.embedded_objects = nil

  # Set to true to embed all objects in the `associated_objects` Hash for an
  # Object. Alternatively, specify individual types to embed by providing an
  # array of type names.
  # Set to false to leave `associated_objects` as-is in the serialization.
  #
  # For example:
  #   config.embed_associated_objects = [Shark::Station, Shark::Vehicle]
  config.embed_associated_objects = false


  # Specify the list of attributes to be included when serializing the Object
  # when nested inside of another (`last_station` on Vehicle, for example).
  # Options work similarly to `serialized_attributes`. Setting to `:all` will
  # include all attributes, while specifying an array of attribute names will
  # only include those attributes.
  # Set to `nil` to not include any attributes in the serialization. In this
  # case, only the identifier will be included in the resulting Hash.
  #
  # For example:
  #   config.nested_serialized_attributes = [:name, :latitude, :longitude]
  #   config.nested_serialized_attributes = nil
  config.nested_serialized_attributes = :all

  # Specify the list of Objects to be embedded when serializing the object when
  # nested inside of another Object. Embedding an Object attribute will
  # transform the identifier that is stored for an Object into a Hash of
  # attributes for that Object (the contents of which is determined by the
  # `nested_serialized_attributes` and `nested_embedded_objects` configuration
  # options for that Object).
  #
  # If set to `:all`, all Object attributes will be embedded. To limit which
  # Objects are embedded, use an array of attribute names.
  # Set to `nil` to not embed any Objects in the serialization.
  #
  # For example:
  #   config.nested_embedded_objects = :all
  #   config.nested_embedded_objects = [:name, :latitude, :longitude]
  config.nested_embedded_objects = nil

  # Set to true to include `associated_objects` in nested embeds. Note that
  # this can lead to infinite loops for objects with cyclical associations.
  config.embed_nested_associated_objects = false
end
