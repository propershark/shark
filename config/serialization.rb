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

  # Set to true to embed all objects in the `associated_objects` Hash for an
  # Object. Alternatively, specify individual types to embed by providing an
  # array of type names.
  # Set to false to leave `associated_objects` as-is in the serialization.
  #
  # For example:
  #   config.embed_associated_objects = [Shark::Station, Shark::Vehicle]
  config.embed_associated_objects = true

  # Specify the list of attributes to be included when serializing the object.
  # If set to true, all attributes will be embedded. To limit which attributes
  # are included, use an array of attribute names.
  # Set to false to not include any attributes in the serialization.
  #
  # The identifier for an object will always be included, regardless of the
  # value for this option.
  #
  # For example:
  #   config.embedded_attributes = [:name, :latitude, :longitude]
  config.embedded_attributes = true

  # Specify the list of attributes to be included when serializing an object
  # that is nested inside of another (`last_station` on Vehicle, for example).
  # Options work similarly to `embedded_attributes`. Setting to true will embed
  # all attributes, while specifying an array of attribute names will only
  # include those attributes.
  # Set to false to not include any attributes in the serialization. In this
  # case, nested objects will be left as just their identifying string.
  #
  # For example:
  #   config.nested_embedded_attributes = [:name, :latitude, :longitude]
  config.nested_embedded_attributes = true

  # Set to true to include `associated_objects` in nested embeds. Note that
  # this can lead to infinite loops with objects with cyclical associations.
  config.embed_nested_associated_objects = false
end
