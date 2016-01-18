get '/update' do
  existing = {
    stops: Stop.all.index_by(&:name),
    routes: Route.all.index_by(&:name),
  }

  gtfs_data = GTFS::Source.build('./data/citybus_gtfs_2015-10-01.zip', strict: false)

  # Import Routes
  Route.import(gtfs_data.routes.map do |r|
    route = existing[:stops][r.long_name] || Route.new
    route.attributes = {
      citybus_id:   r.id,
      name:         r.long_name,
      short_name:   r.short_name,
      description:  r.desc,
      color:        r.color
    }
    route
  end.compact)

  # Import Stops
  Stop.import(gtfs_data.stops.map do |s|
    stop = existing[:stops][s.name] || Stop.new
    stop.attributes = {
      citybus_id:   s.id,
      stop_code:    s.code,
      description:  s.desc,
      name:         s.name,
      location:     "POINT(#{s.lat} #{s.lon})"
    }
    stop
  end.compact)

  existing = {
    stops: Stop.all.index_by(&:description),
    routes: Route.all.index_by(&:short_name),
  }

  # Import Stop data from DoubleMap
  doublemap_data = HTTParty.get('http://citybus.doublemap.com/map/v2/stops')
  Stop.import(doublemap_data.map do |s|
    stop = existing[:stops][s['description']]
    next unless stop
    stop.attributes = {
      doublemap_id: s['id'],
      buddy_id:     s['buddy']
    }
    stop
  end.compact, on_duplicate_key_update: Stop.columns.map(&:name))


  # Import Route data from DoubleMap
  doublemap_data = HTTParty.get('http://citybus.doublemap.com/map/v2/routes')
  Route.import(doublemap_data.map do |r|
    route = existing[:routes][r['short_name']]
    next unless route
    route.attributes = {
      doublemap_id: r['id'],
      path:         r['path'].to_s,
      start_time:   r['start_time'],
      end_time:     r['end_time'],
      active:       r['active'],
      schedule_url: r['schedule_url'],
      stops:        Stop.where(doublemap_id: r['stops']).uniq
    }
    route
  end.compact, on_duplicate_key_update: Route.columns.map(&:name))

  'Success'
end

