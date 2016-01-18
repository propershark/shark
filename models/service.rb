class Service < ActiveRecord::Base
  include SourcedAttributes

  scope :active, ->(date=Date.today) {
    where(date.strftime('%A').downcase => true) \
    .where('? BETWEEN `services`.`start_date` AND `services`.`end_date`', date)
  }

  sources_attributes_from :citybus_gtfs_services do
    configure   source_file:  'data/citybus_gtfs_2015-10-31.zip', table: :calendar_dates

    primary_key       :citybus_id, source: :service_id

    attributes        :monday, :tuesday, :wednesday, :thursday, :friday,
                      :saturday, :sunday, :start_date, :end_date
  end
end
