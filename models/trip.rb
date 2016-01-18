class Trip < ActiveRecord::Base
  include SourcedAttributes

  belongs_to :route
  belongs_to :service
  has_many   :stop_times, -> { order(:index) }, autosave: true
  has_many   :stops, through: :stop_times, autosave: true

  scope :active, ->(date=Date.today) { where(service: Service.active(date)) }
  scope :with_schedules, -> {
    joins(:stop_times) \
    .select(
      '`trips`.*',
      'MIN(`stop_times`.`arrival_time`) as start_time',
      'MAX(`stop_times`.`departure_time`) as end_time'
    ) \
    .group('`trips`.`id`')
  }

  sources_attributes_from :gtfs do
    configure   source_file:  'data/citybus_gtfs_2015-10-31.zip', table: :trips

    primary_key       :citybus_id, source: :id

    attributes        :headsign, :short_name, :direction, :block_id
    aliased_attribute :citybus_id, :id

    association :route, primary_key: :citybus_id, source_key: :route_id
    association :service, primary_key: :citybus_id, source_key: :service_id
  end
end
