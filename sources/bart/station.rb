module BartSource
  class StationSource < Source
    def refresh preserve_cache: false
      api.flush_cache unless preserve_cache
      @data = api.stops.all.lazy.map{ |s| api.stops.get s.id }.map do |station|
        attrs = @station_attributes.each_with_object({}) do |(prop, name), h|
          h[prop] = station.send(name)
        end

        ["stations."+station.abbr, attrs]
      end
    end
  end

  register_source :bart, Shark::Station, StationSource
end
