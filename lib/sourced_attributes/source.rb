module SourcedAttributes
  class Source
    include ::SourcedAttributes::DSL

    # A map of all aliases for concrete Source objects for use by the factory
    # methods.
    @@subclasses = {}

    class << self
      # A factory for creating instances of Source subclasses based on the
      # parameterized name passed in and the list of registered subclasses.
      def create name, opts, klass
        (@@subclasses[name] or Source).new klass, opts
      end

      # Subclasses of Source should register aliases with the factory through
      # this method.
      def register_source name
        @@subclasses[name] = self
      end
    end

    # The default values for source-agnostic options that can be overridden by
    # including new values in the Hash argument to `sources_attributes_from`.
    DEFAULT_OPTIONS = {
      save: true,
      create_new: true,
      batch_size: nil
    }

    def initialize klass, opts={}
      # The model this source is working on.
      @klass = klass
      # A configuration hash for source-agnostic options, passed in as a Hash
      # from the arguments given to the `sources_attributes_from` helper.
      @options = DEFAULT_OPTIONS.merge(opts)
      # A generic configuration hash for source-specific options, managed
      # through the `configure` helper.
      @config = {}
      # The primary key that this source will use to find records to update.
      # `local` is the alias of the primary key in the locally, while `source`
      # is the alias of the primary key in the source data.
      @primary_key = { local: :id, source: :id }
      # A mapping of attributes on the model to field names from the source.
      @attribute_map = {}
      # A mapping of attributes which require special preparation to Procs
      # which can perform that preparation, provided by the configuration.
      @complex_attributes = {}
      # A mapping of attributes which are only to be updated when a given
      # condition is met to Procs which represent that condition.
      @conditional_attributes = {}
      # A list of associations that this source will update. Each entry is a
      # hash, containing the keys :name, :primary_key.
      @associations = []
      # The most recent set of data from the source, formatted as a Hash using
      # the :primary_key values as keys. Updated by `refresh` and used by
      # `apply` to update records.
      @source_data = []
      # The last-retrieved set of data from the source, formatted the same way
      # as @source_data.
      @previous_data = []
      # The records that that the source data will affect. Updated by
      # `refresh_affected_records`.
      @affected_records = {}
    end

    # Given an attribute name and a primary key, resolve the value to be given
    # to that attribute using the configuration supplied through the DSL.
    def resolve_attribute_for_datum attribute, datum
      # The alias of this attribute in the source data
      source_name = @attribute_map[attribute]
      # Complex Attributes are evaluated with the datum as a parameter
      if @complex_attributes.has_key?(attribute)
        @complex_attributes[attribute].call(datum)
      else
        datum[source_name]
      end
    end

    # Create a Hash from the @source_data array, keyed by @primary_key. If
    # @source_data is already a Hash, assume it has already been indexed and do
    # nothing.
    def ensure_indexed_source_data
      return if @source_data.is_a?(Hash)
      @source_data = @source_data.inject({}) do |hash, datum|
        hash[datum[@primary_key[:source]]] = datum
        hash
      end
    end

    # Create new instances of @klass for every key that does not already have
    # an instance associated with it.
    def create_new_records
      @source_data.keys.each do |pk|
        # TODO: Add an option for creating/not creating new records
        @affected_records[pk] ||= @klass.new(@primary_key[:local] => pk)
      end
    end

    # Fill @affected_records with all records affected by the current set of
    # source data, creating new records for any keys which do not yet exist.
    def refresh_affected_records
      # Ensure that the source data is indexed by primary key...
      ensure_indexed_source_data
      # ...so that it can be skimmed to find existing records.
      @affected_records = @klass \
        .where(@primary_key[:local] => @source_data.keys) \
        .index_by(&@primary_key[:local])
      # Then create new objects for the remaining data
      create_new_records if @options[:create_new]
    end

    # Apply the attribute map to the source data for the given record
    def mapped_attributes_for pk
      source = @source_data[pk]
      @attribute_map.inject({}) do |hash, (attribute,_)|
        # Only apply conditional attributes if they're condition is met
        if @conditional_attributes.has_key?(attribute)
          next hash unless @conditional_attributes[attribute].call(source)
        end
        hash[attribute] = resolve_attribute_for_datum(attribute, source)
        hash
      end
    end

    # Apply the current set of source data to the attributes for the given
    # primary key.
    def apply_attributes_to pk, record
      # Map the attributes from the source data to their local counterparts
      # and apply it to the record
      record.assign_attributes(mapped_attributes_for(pk))
    end

    # Apply the current set of source data to the associations for the given
    # primary key.
    def apply_associations_to pk, record
      @associations.each do |config|
        # Get the model that this association references.
        reflection = @klass.reflect_on_association(config[:name])
        # Query the associated model for the records matching the source data
        # keys indicated by :primary_key.
        associated_records = if reflection.collection?
          reflection.klass.where(
            config[:primary_key] => @source_data[pk][config[:source_key]]
          )
        else
          reflection.klass.find_by(
            config[:primary_key] => @source_data[pk][config[:source_key]]
          )
        end
        # Apply the updated association to the record
        record.assign_attributes(config[:name] => associated_records)
      end
    end

    # Perform all of the operations related to updating a sourced record
    def update_record pk, record
      # Update attributes
      apply_attributes_to(  pk, record)
      # Update associations
      apply_associations_to(pk, record)
      # Save the record if it should be
      record.save if (@options[:save] && !@options[:batch_size])
    end

    # Apply the current set of source data to the records it affects
    def apply
      # Make sure the source data is up-to-date
      refresh
      # Make sure the source data is indexed by the primary key
      ensure_indexed_source_data
      # Make sure that all of the affected records are loaded
      refresh_affected_records
      # Wrap all of the updates in a single transaction
      @klass.transaction do
        if @options[:batch_size]
          @affected_records.each_slice(@options[:batch_size]) do |batch|
            @klass.import batch.map{ |pk, record| update_record(pk, record); record }
          end
        else
          @affected_records.each do |pk, record|
            update_record pk, record
          end
        end
      end
    end


    # #
    # Abstract Methods for Subclasses
    # #

    # Talk to the data source to refresh the contents of @source_data.
    def refresh; raise :subclass_responsiblity; end
  end
end
