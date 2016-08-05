require_relative '../middlewares/object_embed'

ObjectEmbed.configure do |config|
  # Set to true to embed all objects in a one-to-many association. For example:
  # when true, a Route will embed object information for each Station in its
  # `stations` attribute; when false, the attribute would be kept as a list of
  # identifiers.
  config.embed_has_many_associations = false
end
