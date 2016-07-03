require_relative 'source/configuration.rb'
require_relative 'source/normal_source.rb'

module Shark
  # This module provides a default Source class that all Sources should inherit
  # from, as well as utilities to register and instantiate new source types
  # based on humanized names.
  module Source
    # Register a new Source class under a humanized name. Source classes will
    # be unique for a given name-object_type pair. That is, multiple Sources
    # can share the same humanized name, but have unique
    def self.register_source name, object_type, klass, fail_on_override: true
      @@sources ||= {}
      key = [name, object_type]
      # Unless supressed, raise an error if a Source is already registered
      # under the given name-object_type pair.
      if @@sources[key] and fail_on_override
        raise "Source #{key} already exists. Use a different name or supress with `fail_on_override: false`."
      else
        @@sources[key] = klass
      end
    end

    # Instantiate a new Source class, the exact type of which is determined by
    # set of currently registered sources and the name-object_type pair given.
    # `configuration` will be passed through to the initializer for the new
    # Source instance.
    def self.create name, object_type, configuration={}
      klass = @@sources[[name, object_type]]
      raise "No Source registered with name #{name} and type #{object_type}." unless klass
      klass.new(configuration)
    end
  end
end
