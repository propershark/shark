require 'httparty'

# A sourcing interface for DoubleMap's public API. Given an agency and a
# datatype, this Source can apply every field from that table onto your models.
class DoubleMapSource < SourcedAttributes::Source
  register_source :doublemap

  # The key used to correlate data between refreshes.
  PRIMARY_KEY = :id

  # The top-level domain and path to the root of the DoubleMap API. Full paths
  # are made by prepending an agency name and appending an endpoint (from the
  # @@endpoints Hash below).
  @@api_domain = '.doublemap.com/map/v2'

  # A map of endpoints to (somewhat) friendlier names for use in the
  # configuration DSL.
  @@endpoints = {
    routes:   '/routes',
    stops:    '/stops',
    vehicles: '/buses'
  }

  def initialize *args
    super *args
    # The data that was retrieved by the previous refresh
    @previous_data = {
      routes: {},
      stops: {},
      vehicles: {}
    }
  end

  def refresh
    # Create a full path by concatenating the agency, domain, and endpoint.
    url = "http://#{@config[:agency]}#{@@api_domain}#{@@endpoints[@config[:endpoint]]}"
    # Pull the data from the API
    doublemap_data = HTTParty.get(url)
    # Map the data into the @source_data object, delegating to the appropriate
    # method to format the data nicely.
    @source_data = send(@config[:endpoint], doublemap_data)
    @previous_data[@config[:endpoint]] = @source_data.inject({}) do |hash, datum|
      hash[datum[PRIMARY_KEY]] = datum
      hash
    end
  end

  def routes raw_data
    # Key the raw data by `short_name`, which the model is expecting, and
    # convert the values into the appropriate types.
    raw_data.map do |record|
      symbolized_record = Hash[record.map{ |(k,v)| [k.to_sym,v] }]
      symbolized_record.inject({}) do |hash, (key,value)|
        hash[key] = case key
        # Time values need to be parsed into Time objects
        when :start_time, :end_time
          Time.parse(value)
        # Path objects need to be parsed into MySQL LINESTRING objects, which
        # is a little more involved. Luckily, we can simply create the WKT
        # string for a LINESTRING, and the rgeo-activerecord gem will take care
        # of converting/saving it for us.
        when :path
          # Convert the raw array into a set of WKT POINT strings
          points = value.each_slice(2).map{ |ll| "#{ll[0]} #{ll[1]}" }
          # Join the POINT strings into the WKT for LINESTRING
          "LINESTRING(#{points.join(',')})"
        # Every other value is fine as-is
        else
          value
        end
        hash
      end
    end
  end


  def stops raw_data
    # Key the raw data by `short_name`, which the model is expecting, and
    # convert the values into the appropriate types.
    raw_data.map do |record|
      symbolized_record = Hash[record.map{ |(k,v)| [k.to_sym,v] }]
      symbolized_record[:code] = symbolized_record[:name][/BUS\w*/]
      symbolized_record
    end
  end


  def vehicles raw_data
    midnight = Time.now.midnight
    # Update the data hash from the source data
    data = raw_data.map do |record|
      symbolized_record = Hash[record.map{ |(k,v)| [k.to_s.underscore.to_sym,v] }]
      symbolized_record[:code] = symbolized_record.delete(:name)
      # Store the last_update for this vehicle in seconds since midnight for
      # easier comparison with stop times, etc.
      time_since_midnight = Time.at(symbolized_record[:last_update].to_i) - midnight
      symbolized_record[:last_update] = time_since_midnight

      # The following are dependent on the data from the previous refresh
      previous_record = @previous_data[:vehicles][symbolized_record[:id]] || {}
      # If the vehicle was not included in the previous refresh, assume that it
      # started its trip at this time.
      symbolized_record[:started_at] = time_since_midnight if previous_record.empty?
      # If the last stop has changed, update departed_at to this time
      if symbolized_record[:last_stop] != previous_record[:last_stop]
        symbolized_record[:departed_at] = time_since_midnight
      end

      symbolized_record
    end

    data
  end
end
