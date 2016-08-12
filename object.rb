require 'set'

require_relative 'object_serialization'

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


      # Attributes defined with the `attribute` macro are:
      #   - Assignable and initializable via Hash arguments.
      #   - Included in the Hash representation of the object.
      attr_accessor :attributes
      def attribute *args
        (@attributes ||= []).concat(args)
        attr_accessor(*args)
      end

      # The primary attribute of an Object is the attribute that can be used to
      # uniquely identify the object.
      attr_accessor :identifying_attribute
      def primary_attribute name
        @identifying_attribute = name
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
    end

    include Configurable
    inherit_configuration_from self

    include ObjectSerialization


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


    # Add the given object as an associate to this object.
    def associate klass, identifier
      @associated_objects[klass].add(identifier)
    end

    # Remove any association with the given object.
    def dissociate klass, identifier
      @associated_objects[klass].delete(identifier)
    end

    # Remove all associations of the given type from this object.
    def dissociate_all klass
      @associated_objects[klass].clear
    end

    # Return true if this object has an association record with the given
    # object.
    def has_association_to klass, identifier
      @associated_objects[klass].include?(identifier)
    end


    # For every attribute given in `args`, assign it's value on this Object to
    # the provided value.
    def assign args={}
      args.keys.each{ |name| instance_variable_set("@#{name}", args[name]) }
    end

    # Return the value of the primary attribute on this Object.
    def identifier
      send(self.class.identifying_attribute)
    end
  end
end
