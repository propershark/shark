require_relative 'schemable/property'
require_relative 'schemable/schema'

module Shark
  module Schemable
    # Return the current Schema object. If a `block` is given, it will first be
    # executed with the Schema object as the receiver before returning.
    # If a block is given and `validate_on_set` is true, the schema will be
    # used to validate `self` after evaluating the block.
    def schema validate_on_set: true, **options, &block
      @schema ||= Schema.new(**options)
      # Apply new options for the schema
      @schema.options.merge!(options)
      # Evaluate any schema definition that is given
      if block_given?
        @schema.instance_eval(&block)
        @schema.validate(self) if validate_on_set
      end
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
    # required, non-nilable property in the schema.
    attr_accessor :identifying_attribute
    def primary_attribute name
      @identifying_attribute = name
      # Find the property with the given name in the schema. If it exists,
      # ensure that it is required.
      prop = schema.properties.find{ |prop| prop.name == name }
      prop&.required = true
      prop&.nilable = false
    end
  end
end
