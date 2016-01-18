module SourcedAttributes
  module DSL
    # Set options specific to this Source instance.
    def configure options={}
      @config.merge! options
    end

    # Set the primary key that this Source will use to find records to update.
    def primary_key local, opts={}
      @primary_key = { local: local, source: opts[:source] || local }
    end

    # Short-hand for defining attributes whose local names map directly to
    # field names in the source data.
    def attributes *args
      args.each{ |arg| @attribute_map[arg] = arg }
    end

    # Define an attribute whose local name is different from its name in the
    # source data.
    def aliased_attribute local_name, source_name
      @attribute_map[local_name] = source_name
    end

    def complex_attribute local_name, &block
      attributes local_name
      @complex_attributes[local_name] = block
    end

    # Conditional attributes only get updated when the block is true. If no
    # block is given, a default block checking for the presence of the
    # attribute in the source data will be used
    def conditional_attribute local_name, &block
      attributes local_name
      if block_given?
        @conditional_attributes[local_name] = block
      else
        @conditional_attributes[local_name] = ->(record) { record[local_name] }
      end
    end

    # Define an association whose value comes from the source data.
    # `primary_key` here is the primary key to use for the associated table.
    # `source_key` is the key to pick out of the source data.
    def association name, options={}
      options[:name] ||= name
      options[:source_key] ||= options[:name]
      @associations << options
    end
  end
end
