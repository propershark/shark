require_relative 'gtfs_source.rb'

# Services are really a combination of two tables from a GTFS dump: `calendar`
# and `calendar_dates`. This Source combines the two into a usable source_data.
class GTFSServicesSource < GTFSSource
  register_source :citybus_gtfs_services

  def refresh
    # Get the GTFS object for this instance's source file.
    source_file = @config[:source_file]
    @@sources[source_file] ||= load(source_file)
    # A map of service IDs to services
    services = {}
    # Load the calendar table, if it exists
    table = @@sources[source_file].calendar_dates
    services = table.inject({}) do |hash, record|
      date = Date.parse(record.date)
      weekday = date.strftime('%A').downcase.to_sym
      hash[record.service_id] ||= {}
      hash[record.service_id][:service_id] ||= record.service_id
      hash[record.service_id][weekday] = record.exception_type % 2
      hash[record.service_id][:start_date] ||= date
      hash[record.service_id][:start_date] = date if date < hash[record.service_id][:start_date]
      hash[record.service_id][:end_date] ||= date
      hash[record.service_id][:end_date] = date if date > hash[record.service_id][:end_date]

      hash
    end

    @source_data = services.values
  end
end
