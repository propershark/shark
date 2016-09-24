require 'set'

require_relative 'serializable'

module Shark
  # Wrapping class for objects to allow hash-based initialization and updating
  # of attributes.
  class Object
    class << self
      include Configurable

      def inherited subclass
        subclass.class_exec do
          # Automatically inherit configuration from the base Object class for
          # all subclasses.
          class << self
            include Configurable
            inherit_configuration_from Shark::Object
          end

          include Configurable
          inherit_configuration_from self
        end
      end


      # Return the universally-unique identifier that an object of this type
      # would have if it had the given local identifier. If this method is not
      # overridden by an Object type, the default will be the type name in a
      # naively-plural form, followed by a `.` and the local identifier. EX:
      #     Route.identifier_for "1A"       ->    routes.1A
      #     Vehicle.identifier_for "4005"   ->    vehicles.4005
      def identifier_for identifier
        "#{name.gsub(/^.*::/,'').downcase}s.#{identifier}"
      end

      # Return the current version of this type, as set by its schema.
      def version; schema.version; end
      def version= new_version
        schema.version = new_version
      end
    end
    extend Schemable

    include Configurable
    inherit_configuration_from self
    configuration.schema validate_on_set: false do
      optional :serialized_attributes, default: :all do
        value_alias :all, real_value: ->{ attributes }
        value_alias nil,  real_value: []
      end
      optional :embedded_objects, default: nil do
        value_alias :all, real_value: ->{ attributes }
        value_alias nil,  real_value: []
      end
      optional :embed_associated_objects, default: false

      optional :nested_serialized_attributes, default: :all do
        value_alias :all, real_value: ->{ attributes }
        value_alias nil,  real_value: []
      end
      optional :nested_embedded_objects, default: nil do
        value_alias :all, real_value: ->{ attributes }
        value_alias nil,  real_value: []
      end
      optional :nested_embed_associated_objects,  default: false
    end

    include Serializable


    # Objects can maintain lists of objects with which they associate. This is
    # useful for keeping track of a changing set of related objects (as
    # opposed to a static set) such as Vehicles arriving at a Station.
    # `associated_objects` is a Hash of object types to lists of identifiers.
    attr_accessor :associated_objects


    # Instantiate a new Object, initializing the attributes provided. Other
    # attributes will not be given a value.
    def initialize args={}
      assign(args)
      @associated_objects = Hash.new{ |h, k| h[k] = Set.new }
    end


    # Add the given object as an associate to this object. Return `true` if the
    # association is newly created, or `false` if it already existed.
    def associate klass, ident
      @associated_objects[klass].add?(ident) != nil
    end

    # Remove any association with the given object. Return `true` if the
    # association was removed by this call, or `false` if it did not exist.
    def dissociate klass, ident
      @associated_objects[klass].delete?(ident) != nil
    end

    # Remove all associations of the given type from this object. If no type is
    # given, all associations will be removed.
    def dissociate_all klass=nil
      if klass
        @associated_objects[klass].clear
      else
        @associated_objects.clear
      end
    end

    # Return true if this object has an association record with the given
    # object.
    def has_association_to klass, ident
      @associated_objects[klass].include?(ident)
    end

    # Return the version of this object, as set by its schema.
    def version
      self.class.version
    end


    # For every attribute given in `args`, assign it's value on this Object to
    # the provided value.
    def assign args={}
      args.keys.each{ |name| instance_variable_set("@#{name}", args[name]) }
    end

    # Return the value of the primary attribute on this Object.
    def identifier
      self.class.identifier_for(send(self.class.identifying_attribute))
    end
  end
end
