require_relative 'schemable/property'
require_relative 'schemable/schema'

module Shark
  module Schemable
    # Return the current Schema object. If a `block` is given, it will first be
    # executed with the Schema object as the receiver before returning.
    def schema &block
      @schema ||= Schema.new
      @schema.instance_eval(&block) if block_given?
      @schema
    end
    attr_writer :schema


    # The list of attributes defined for this Object. Defining an attribute
    # via `attribute` will add it to the schema, as well as create accessors
    # for that attribute
    def attributes; @attributes ||= []; end
    def attribute arg, **options, &block
      schema.property(arg, **options, &block)
      attributes << arg
      attr_accessor arg
    end

    # The primary attribute of an Object is the attribute that can be used to
    # uniquely identify the object. By that nature, it will also be made a
    # required property in the schema.
    attr_accessor :identifying_attribute
    def primary_attribute name
      @identifying_attribute = name
      # Find the property with the given name in the schema. If it exists,
      # ensure that it is required.
      schema.properties.find{ |prop| prop.name == name }&.required = true
    end
  end
end
