require 'gtfs'

# A generic sourcing interface for GTFS dumps. Provided a source file and a
# specific table to read, this Source can apply every field from that table
# onto your models.
class GTFSSource < SourcedAttributes::Source
  register_source :gtfs

  # A map of source file names to loaded GTFS objects.
  # Since GTFS dumps contain multiple files, they are often used for multiple
  # models. To reduce overhead, we can load a dump once and save it here,
  # then access that same dump from any other GTFSSource instance.
  @@sources = {}

  def refresh
    # Get the GTFS object for this instance's source file.
    source_file = @config[:source_file]
    @@sources[source_file] ||= load(source_file)
    # Pick out the table of data for this instance, index it by ID, and load it
    # into @source_data so that `apply` can load it onto the models.
    table = @@sources[source_file].send(@config[:table])
    @source_data = table.each_with_index.map do |record, row_num|
      data = record.instance_variables.inject({}) do |hash, var|
        value = record.instance_variable_get(var)
        hash[var[1..-1].to_sym] = case value
        when String
          value.strip
        else
          value
        end
        hash
      end
      data[:_row_num] = row_num
      data
    end
  end

  # Build and store a new GTFS object for later use.
  def load file_name
    GTFS::Source.build(file_name, strict: false)
  end
end
