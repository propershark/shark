class AddTripsAndStopTimes < ActiveRecord::Migration
  def change
    create_table :stop_times, options: 'ENGINE=Aria' do |t|
      t.string      :citybus_id,          index: true
      t.belongs_to  :trip,                index: true
      t.belongs_to  :stop,                index: true
      t.time        :departure_time
      t.time        :arrival_time
      t.integer     :index
      t.string      :headsign
      t.integer     :pickup_type
      t.integer     :drop_off_type
      t.decimal     :distance_traveled,   precision: 9, scale: 3
    end


    create_table :trips, options: 'ENGINE=Aria' do |t|
      t.string      :citybus_id,          index: true
      t.belongs_to  :route,               index: true
      t.belongs_to  :service,             index: true
      t.string      :headsign
      t.string      :short_name
      t.integer     :direction
      t.string      :block_id,            index: true
    end

    create_table :services do |t|
      t.string      :citybus_id,          index: true
      t.boolean     :monday,              default: false
      t.boolean     :tuesday,             default: false
      t.boolean     :wednesday,           default: false
      t.boolean     :thursday,            default: false
      t.boolean     :friday,              default: false
      t.boolean     :saturday,            default: false
      t.boolean     :sunday,              default: false

      t.date        :start_date
      t.date        :end_date
    end
  end
end
